import re, kubernetes, yaml, logging
from struct import unpack
import dateutil.parser
from benedict import benedict
from typing import Optional, Union
from RW import platform
from enum import Enum
from .k8s_connection_mixin import K8sConnectionMixin
from .deployment_tasks_mixin import DeploymentTasksMixin
from .event_tasks_mixin import EventTasksMixin
from .pvc_tasks_mixin import PvcTasksMixin
from .pod_tasks_mixin import PodTasksMixin
from .pdb_tasks_mixin import PdbTasksMixin
from .network_tasks_mixin import NetworkTasksMixin
from .statefulset_tasks_mixin import StatefuletTasksMixin
from .job_tasks_mixin import JobTasksMixin
from .daemonset_tasks_mixin import DaemonsetTasksMixin
from RW.Utils.utils import dict_to_yaml
from RW.Utils.utils import yaml_to_dict
from RW.Utils.utils import stdout_to_list
from RW.Utils.Check import Check

logger = logging.getLogger(__name__)

class NamespaceTasksMixin(
    K8sConnectionMixin,
    DeploymentTasksMixin,
    EventTasksMixin,
    PvcTasksMixin,
    PodTasksMixin,
    PdbTasksMixin,
    NetworkTasksMixin,
    JobTasksMixin,
    DaemonsetTasksMixin,
    StatefuletTasksMixin
    ):

    def get_object_names(self, k8s_items, distinct_values:bool=True) -> list:
        object_names : list = []
        if "items" in k8s_items:
            k8s_items = k8s_items["items"]
        for item in k8s_items:
            item : benedict = benedict(item, keypath_separator=None)
            kind : str = item["kind"]
            name : str = item["metadata", "name"]
            object_name : str = f"{kind}/{name}"
            if distinct_values is True and object_name not in object_names:
                object_names.append(object_name)
            else:
                object_names.append(object_name)
        return object_names

    def get_objects_by_name(self, names: list, namespace: str, context:str, target_service: platform.Service, kubeconfig: platform.Secret) -> list:
        list_of_k8s_objects : list= []
        for name in names:
            stdout = self.shell(
                cmd=f"kubectl get {name} --context={context} --namespace={namespace} -o yaml",
                target_service=target_service,
                kubeconfig=kubeconfig
            )
            if stdout:
                k8s_object = yaml_to_dict(stdout)
                list_of_k8s_objects.append(k8s_object)
        return list_of_k8s_objects
    
    def search_namespace_objects_for_string(
        self,
        k8s_items,
        search_string: str
    ) -> list:
        found_in_objects : list = []
        if "items" in k8s_items:
            k8s_items = k8s_items["items"]
        for item in k8s_items:
            yaml = dict_to_yaml(item)
            if search_string in yaml:
                found_in_objects.append(item)
        return found_in_objects
    
    def _troubleshoot_namespace_objects(
        self,
        object_name,
        context : str,
        namespace: str,
        kubeconfig : platform.Secret,
        target_service : platform.Service,
        binary_name: str = "kubectl",
    ) -> dict:
        troubleshoot_results = {}
        if object_name.startswith("event.events.k8s.io/") or object_name.startswith("event/"):
            pass #TODO: determine useful event troubleshoot data in this context
        elif object_name.startswith("deployment.apps/"):
            stdout = self.shell(
                f"{binary_name} get {object_name} --context={context} --namespace={namespace} -o yaml",
                target_service,
                kubeconfig,
            )
            deployment = yaml_to_dict(stdout)
            troubleshoot_results = self.check_resources(deployment, object_name)
        elif object_name.startswith("pod/"):
            stdout = self.shell(
                f"{binary_name} get {object_name} --context={context} --namespace={namespace} -o yaml",
                target_service,
                kubeconfig,
            )
            pod = yaml_to_dict(stdout)
            troubleshoot_results = self.check_pods(pods=pod)
        elif object_name.startswith("persistentvolumeclaim/"):
            stdout = self.shell(
                f"{binary_name} get {object_name} --context={context} --namespace={namespace} -o yaml",
                target_service,
                kubeconfig,
            )
            pvc = yaml_to_dict(stdout)
            troubleshoot_results = self.check_pvc(pvcs=pvc)
        return troubleshoot_results

    def check_namespace_objects(
        self,
        k8s_object_names,
        context : str,
        namespace: str,
        kubeconfig : platform.Secret,
        target_service : platform.Service,
        binary_name: str = "kubectl",
    ) -> str:
        checks: list(Checks) = []
        checks.append(Check(
            title=f"Found and applied troubleshooting for the following objects in namespace: {namespace}:\n",
        ))
        for k8s_object_name in k8s_object_names:
            results = self._troubleshoot_namespace_objects(
                k8s_object_name,
                context,
                namespace,
                kubeconfig,
                target_service,
                binary_name,
            )
            if "check_passed" in results:
                status = results["check_passed"]
                checks.append(Check(
                    title=f"\tObject {k8s_object_name} troubleshoot pass/fail status:",
                    symbol=bool(status),
                ))
        return "\n".join([str(c) for c in checks])

    def check_namespace_errors(
        self,
        context : str,
        namespace: str,
        kubeconfig : platform.Secret,
        target_service : platform.Service,
        binary_name: str = "kubectl",
        error_pattern: str = "(Error|Exception)",
    ) -> str:
        checks: list(Checks) = []
        stdout: str = self.shell(
            f"{binary_name} get Events --context={context} --namespace={namespace} -o yaml", 
            target_service,
            kubeconfig
        )
        events: dict = yaml_to_dict(stdout)
        if "items" in events:
            events_count = len(events["items"])
        else:
            events_count = len(events)
        events_involved_objects : list = self.get_involved_object_name_list(events)
        stdout: str = self.shell(
            f"{binary_name} get pods --context={context} --namespace={namespace} --field-selector=status.phase==Running -o yaml",
            target_service,
            kubeconfig
        )
        pods: dict = yaml_to_dict(stdout)
        pod_object_names: list(str) = self.get_object_names(pods)
        pod_log_mapping: dict = {}
        for pod_object_name in pod_object_names:
            cmd: str = f"{binary_name} logs --context={context} --namespace={namespace} {pod_object_name} --tail=100 | grep -E -i \"{error_pattern}\""
            try:
                stdout = self.shell(
                    cmd,
                    target_service,
                    kubeconfig
                )
                pod_log_mapping[pod_object_name] = stdout
            except:
                logger.warning(f"Unable to fetch logs from pod {pod_object_name} with command: {cmd}")
        pods_with_error_logs : list = []
        for pod_object_name, pod_logs in pod_log_mapping.items():
            if pod_logs:
                pods_with_error_logs.append(pod_object_name)
        checks.append(Check(
            title=f"No non-info events found in namespace {namespace}",
            symbol=bool(events_count == 0),
        ))
        if events_count > 0:
            events_involved_objects = "\n\t\t".join(events_involved_objects)
            checks.append(Check(
                title=f"Total non-info events found in namespace: {namespace}: ",
                value=f"{events_count}",
            ))
            checks.append(Check(
                title=f"Objects with non-info events in namespace: {namespace}:\n",
                value=f"""{events_involved_objects}""",
            ))
        checks.append(Check(
            title=f"Pod workloads in namespace {namespace} do not have errors in recent logs: ",
            symbol=bool(len(pods_with_error_logs) == 0),
        ))
        if len(pods_with_error_logs) > 0:
            pods_with_error_logs: str = "\n\t\t".join(pods_with_error_logs)
            checks.append(Check(
                title=f"Running pod workloads with error entries in their logs:",
                value=f"{pods_with_error_logs}",
            ))
        return "\n".join([str(c) for c in checks])
    
    def get_event_count(
        self,
        namespace:str,
        context:str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        event_pattern:str = "*",
        binary_name: str = "kubectl",
        event_type: str = "Warning"
    ) -> int:
        events_stdout: str = self.shell(
            cmd=f"{binary_name} get events -n {namespace} --context {context} --no-headers --field-selector type={event_type} | grep -E -i \"{event_pattern}\"",
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        if events_stdout:
            event_rows: list = stdout_to_list(events_stdout, delimiter="\n")
            return len(event_rows)
        else:
            return 0
