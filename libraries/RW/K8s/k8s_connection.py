import re, kubernetes, yaml, logging, json
from struct import unpack
import dateutil.parser
from benedict import benedict
from typing import Optional, Union, Generator
from RW import platform
from enum import Enum
from RW.Utils.utils import stdout_to_list
from RW.Utils.utils import search_json


logger = logging.getLogger(__name__)


class K8sConnection:
    """
    Static class that is used to provide other classes in the K8s keyword library
    with a standardized mode of communicating with Kubernetes Clusters.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    # stderr that is considered a success when received from a location service (regex)
    # eg: when a 'kubectl get pods' returns no resources, this has a returncode of 1, and stderr, even though it's generally considered 'ok'
    ALLOWED_STDERR = [
        # "", # Allow empty string because we may grep and filter values resulting in empty - leave commented
        "Defaulted container",  # Allow defaulting to a container in a pod
        "Error from server (NotFound)",
        "No resources found in",
    ]

    shell_history: list[str] = []
    last_shell_command: str = None

    class DistributionOption(Enum):
        KUBERNETES = "Kubernetes"
        GKE = "GKE"
        OPENSHIFT = "OpenShift"

    @staticmethod
    def clear_shell_history():
        K8sConnection.shell_history = []

    @staticmethod
    def pop_shell_history():
        history = K8sConnection.get_shell_history()
        K8sConnection.clear_shell_history()
        return history

    @staticmethod
    def get_shell_history():
        return K8sConnection.shell_history

    @staticmethod
    def get_last_shell_command():
        return K8sConnection.last_shell_command

    @staticmethod
    def get_binary_name(distrib_option: str) -> str:
        if distrib_option in [
            K8sConnection.DistributionOption.KUBERNETES.value,
            K8sConnection.DistributionOption.GKE.value,
        ]:
            return "kubectl"
        if distrib_option == K8sConnection.DistributionOption.OPENSHIFT.value:
            return "oc"
        raise ValueError(f"Could not select a valid distribution option using option: {distrib_option}")

    @staticmethod
    def shell(
        cmd: str,
        target_service: platform.Service,
        kubeconfig: platform.Secret,
        shell_secrets=[],
        shell_secret_files=[],
    ):
        """Execute a shell command, which can contain kubectl (or equivalent).
        Returns a RW.platform.ShellServiceResponse
        object with the stdout, stderr, returncode, etc.

        Args:
            cmd (str): an arbitrary shell command. eg: kubectl get pods | grep myapi
            target_service (platform.Service): which runwhen location service to use.
            kubeconfig (platform.Secret): a kubeconfig containing in a platform secret.
            shell_secrets (list(platform.Secret)): a list of platform secret values which can be accessed in the shell command with '$key'.
            shell_secret_files (list(platform.Secret)): a list of platform secret values to be accessible as files on the location service.

        Example:
        (in suite setup)
        ${kubeconfig}=  RW.Import Secret    kubeconfig
        ${kubectl}=     RW.Import Service   kubectl
        ${rsp}=         RW.K8s.Shell  kubectl get pods -n default
        ...             service=${kubectl}
        ...             kubeconfig=${kubeconfig}
        RW.Core.Add To Report   result of kubectl cmd was ${rsp.stdout} with err ${rsp.stderr}

        Returns:
            RW.platform.ShellServiceResponse: a dataclass containing the response from the location service, including stdout.
        """
        if not target_service:
            raise ValueError("A runwhen service was not provided for the kubectl command")
        K8sConnection.shell_history.append(cmd)
        K8sConnection.last_shell_command = cmd
        logger.info("requesting command: %s", cmd)
        request_secrets: [platform.ShellServiceRequestSecret] = []
        request_secrets.append(platform.ShellServiceRequestSecret(kubeconfig, as_file=True))
        for shell_secret in shell_secrets:
            request_secrets.append(platform.ShellServiceRequestSecret(shell_secret))
        for shell_secret_file in shell_secret_files:
            request_secrets.append(platform.ShellServiceRequestSecret(shell_secret_file, as_file=True))
        env = {"KUBECONFIG": f"./{kubeconfig.key}"}
        rsp = platform.execute_shell_command(cmd=cmd, service=target_service, request_secrets=request_secrets, env=env)
        if (
            (rsp.status != 200 or rsp.returncode > 0)
            and rsp.stderr != ""
            and not any(partial_stderr in rsp.stderr for partial_stderr in K8sConnection.ALLOWED_STDERR)
        ):
            raise ValueError(
                f"The shell service responded with HTTP: {rsp.status} RC: {rsp.returncode} and response: {rsp}"
            )
        logger.info("shell stdout: %s", rsp.stdout)
        return rsp.stdout

    @staticmethod
    def template_workload(
        workload_name: str,
        workload_namespace: str,
        workload_container: str,
        target_service: platform.Service = None,
        kubeconfig: platform.Secret = None,
        context: str = "",
    ) -> str:
        """Take in the workload variables and construct a valid string that specifies the namespace and container.

        Args:
            workload_name (str): a workload type in which a pod can be found such as deployment/my-deployment or statefulset/my-statefulset. Also accepts labels if starting with `-l`
            workload_namespace (str): a kubernetes namespace or openshift project name
            workload_container (str): a specific container within a pod, as pods may not default to the desired container

        Returns:
            workload: a string containing the the expanded workload parameters.
        """
        # Check if the namespace is provided in the workload name and return the value verbatim
        if " -n" in workload_name or " --namespace" in workload_name:
            workload = f"{workload_name}"
            return workload
        # Check if we are passing labels instead of a distinct resource, then fetch pod name by label
        if "-l" in workload_name:
            resource_labels = workload_name.lstrip("-l ")
            cmd = f"kubectl get pods -l {resource_labels} -n {workload_namespace} --context {context} -o json"
            pod_details: str = K8sConnection.shell(
                cmd=cmd,
                target_service=target_service,
                kubeconfig=kubeconfig,
            )
            pod_names = search_json(data=json.loads(pod_details), pattern="items[].metadata.name")
            workload_name = f"pod/{pod_names[0]}"
        if not workload_name:
            raise ValueError(f"Error: No workload is specified.")
        if not workload_namespace:
            raise ValueError(f"Error: Namespace is not specified.")
        if not workload_container:
            workload = f"{workload_name} -n {workload_namespace}"
        else:
            workload = f"{workload_name} -n {workload_namespace} -c {workload_container}"
        return workload

    @staticmethod
    def template_shell(
        cmd: str,
        target_service: platform.Service,
        kubeconfig: platform.Secret,
        **kwargs,
    ):
        """Similar to `shell` to run a shell command, except you may provide a templated string
        representing the shell command you wish to run.
        eg: 'kubectl get pod/{my_pod_name}'
        The templated string is formatted with values from **kwargs.

        Args:
            cmd (str): an arbitrary shell command. eg: kubectl get pods | grep myapi
            target_service (platform.Service): which runwhen location service to use.
            kubeconfig (platform.Secret): a kubeconfig containing in a platform secret.

        Returns:
            RW.platform.ShellServiceResponse: a dataclass containing the response from the location service, including stdout.
        """
        logger.info("templating a shell command: %s with the kwargs: %s", cmd, kwargs)
        cmd = cmd.format(**kwargs)
        return K8sConnection.shell(cmd=cmd, target_service=target_service, kubeconfig=kubeconfig)

    @staticmethod
    def loop_template_shell(
        items: list,
        cmd: str,
        target_service: platform.Service,
        kubeconfig: platform.Secret,
        include_empty: bool = False,
        newline_as_separate: bool = False,
        fail_on_exception: bool = False,
    ) -> list:
        outputs: list = []
        for item in items:
            try:
                output = K8sConnection.template_shell(
                    cmd,
                    target_service,
                    kubeconfig,
                    item=item,
                )
                if output or include_empty is True:
                    if newline_as_separate:
                        output = stdout_to_list(output, delimiter="\n")
                        if not include_empty:
                            output = [output_val for output_val in output if output_val]
                        if output:
                            outputs += output
                    else:
                        outputs.append(output)
            except Exception as e:
                if fail_on_exception:
                    raise Exception(f"Encountered exception: {e} on item {item}")
                logger.warning(f"Encountered exception: {e} on item {item} - continuing to next item")
        return outputs

    # @staticmethod
    # def paginated_shell(
    #     cmd: str,
    #     target_service: platform.Service,
    #     kubeconfig: platform.Secret,
    #     shell_secrets=[],
    #     shell_secret_files=[],
    #     page_size:int=100,
    # ) -> Generator:
    #     counter: int = 0
    #     last_results: dict = {}
    #     results = K8sConnection.shell(cmd=cmd, target_service=target_service, kubeconfig=kubeconfig)
    #     counter += 1
    #     pass
