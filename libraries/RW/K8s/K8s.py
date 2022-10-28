"""
K8s keyword library, version 2, based on shellservice base.

Scope: Global
"""
import re, kubernetes, yaml
from struct import unpack
import dateutil.parser
from benedict import benedict
from typing import Optional, Union
from RW import platform
from enum import Enum


class K8s:
    # TODO: rework to K8s v3 design, comprehensive logging, reorganize and improve docs
    """
    K8s keyword library can be used to interact with Kubernetes clusters.
    """

    class DistributionOption(Enum):
        KUBERNETES = "Kubernetes"
        GKE = "GKE"
        OPENSHIFT = "OpenShift"

    class MuteOption(Enum):
        YES = "Yes"
        NO = "No"

    class ReportSymbol(Enum):
        CHECKMARK = "\u2713"
        X = "\u2717"

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        pass

    def get_binary_name(self, distrib_option: str) -> str:
        if distrib_option in [K8s.DistributionOption.KUBERNETES.value, K8s.DistributionOption.GKE.value]:
            return "kubectl"
        elif distrib_option == K8s.DistributionOption.OPENSHIFT.value:
            return "oc"
        else:
            raise ValueError(f"Could not select a valid distribution option using option: {distrib_option}")

    def _get_client(self, kubeconfig: str):
        client = kubernetes.dynamic.DynamicClient(
            kubernetes.config.new_client_from_config_dict(
                yaml.safe_load(kubeconfig)
            )
        )
        return client

    def kubectl(
        self,
        cmd: str,
        target_service: platform.Service,
        kubeconfig: platform.Secret,
    ):
        """Execute a kubectl command.  Returns a RW.platform.ShellServiceResponse
        object with the stdout, stderr, returncode, etc.

        Example:
        (in suite setup)
        ${kubeconfig}=  RW.Import Secret    kubeconfig
        ${kubectl}=     RW.Import Service   kubectl
        ${rsp}=      RW.Kubectl get pods -n default
        ...             service=${kubectl}
        ...             kubeconfig=${kubeconfig}
        RW.Core.Add To Report   result of kubectl cmd was ${rsp.stdout} with err ${rsp.stderr}
        """
        if not cmd.strip().startswith("kubectl") and not cmd.strip().startswith("oc"):
            cmd = f"kubectl {cmd}"
        s = platform.ShellServiceRequestSecret(kubeconfig, as_file=True)
        env = {"KUBECONFIG": "./kubeconfig"}
        return platform.execute_shell_command(
            cmd=cmd, service=target_service, request_secrets=[s], env=env
        )

    def _api_client_get(self, kind, kubeconfig, **kwargs):
        api_version = kwargs.get("api_version", "v1")
        # TODO: pass context to client
        context = kwargs.get("context", None)
        client = self._get_client(kubeconfig)
        try:
            api = client.resources.get(api_version=api_version, kind=kind)
            rsp = api.get(**kwargs)
            # if we get nothing back, validation should check this result
        except kubernetes.dynamic.exceptions.NotFoundError:
            return None
        except kubernetes.dynamic.exceptions.ResourceNotFoundError:
            return None
        rsp = benedict(self.k8s_to_dict(rsp), keypath_separator=None)
        return rsp

    def _kubectl_get(self, kind, kubeconfig, target_service: platform.Service = None, distribution: str = "Kubernetes", **kwargs):
        if not target_service:
            raise ValueError(
                "A runwhen service was not provided for the kubectl command"
            )
        kubectl_command = self.compose_kubectl_command(
            binary_name=self.get_binary_name(distribution), kind=kind, verb="get", **kwargs
        )
        rsp = self.kubectl(kubectl_command, target_service, kubeconfig)
        if rsp.status != 200:
            raise ValueError(
                "The kubectl shell service responded with HTTP: {rsp.status} RC: {rsp.returncode} and response: {rsp}"
            )
        if rsp.returncode > 0:
            # match api client behaviour, assume resource/object not found
            return None
        rsp = self.yaml_to_dict(rsp.stdout)
        return rsp

    def get(
        self,
        kind: str,
        kubeconfig: platform.Secret,
        api_version: str = "v1",
        name: str = None,
        label_selector: str = None,
        field_selector: str = None,
        context: str = None,
        namespace: str = None,
        unpack_from_items: str = None,
        output_format: str = "dict",
        target_service: platform.Service = None,
        distribution: str = "Kubernetes",
        **kwargs,
    ):
        rsp = None
        if not target_service:
            rsp = self._api_client_get(
                kind=kind,
                kubeconfig=kubeconfig.value,
                api_version=api_version,
                name=name,
                label_selector=label_selector,
                field_selector=field_selector,
                context=context,
                namespace=namespace,
                target_service=target_service,
                distribution=distribution,
                **kwargs,
            )
        elif target_service:
            rsp = self._kubectl_get(
                kind=kind,
                kubeconfig=kubeconfig,
                api_version=api_version,
                name=name,
                label_selector=label_selector,
                field_selector=field_selector,
                context=context,
                namespace=namespace,
                target_service=target_service,
                distribution=distribution,
                **kwargs,
            )
        else:
            raise ValueError("Could not determine Kubernetes API call method")
        if unpack_from_items is not None and (
            unpack_from_items.title() == "True" or unpack_from_items is True
        ):
            if "items" in rsp:
                rsp = rsp["items"]
        if output_format == "yaml":
            rsp = self.dict_to_yaml(rsp)
        return rsp

    def stateful_sets_ready(
        self, statefulsets, unpack_from_items: str = "True"
    ):
        if unpack_from_items.title() == "True" and "items" in statefulsets:
            statefulsets = statefulsets["items"]
        # validate list of statefulsets
        if isinstance(statefulsets, list):
            for statefulset in statefulsets:
                statefulset = benedict(statefulset, keypath_separator=None)
                desired = int(statefulset["status", "replicas"])
                if ["status", "readyReplicas"] in statefulset:
                    ready = int(statefulset["status", "readyReplicas"])
                else:
                    ready = 0
                if desired != ready:
                    return False
        # validate singular statefulset
        elif isinstance(statefulsets, dict) and "items" not in statefulsets:
            statefulset = benedict(statefulset, keypath_separator=None)
            desired = int(statefulset["status", "replicas"])
            if ["status", "readyReplicas"] in statefulset:
                ready = int(statefulset["status", "readyReplicas"])
            else:
                ready = 0
            if desired != ready:
                return False
        else:
            raise KeyError(
                f"Stateful sets object is malformed {statefulsets}, is it well-formed and unpacked from items?"
            )
        return True

    def k8s_to_dict(self, objs):
        k8s_dict = objs.to_dict()
        return k8s_dict

    def k8s_to_yaml(self, objs):
        return yaml.dump(objs.to_dict())

    def yaml_to_dict(self, yaml_str):
        return yaml.safe_load(yaml_str)

    def dict_to_yaml(self, data):
        if isinstance(data, benedict):
            return data.to_yaml()
        return yaml.dump(data)

    # TODO: cleanup checks and abstract to well organized mixin
    def check_events(
        self,
        kubeconfig,
        namespace,
        search_name,
        context=None,
        labels=None,
        field_selector=None,
        number_of_warnings=5,
        target_service: platform.Service = None,
        distribution: str = "Kubernetes",
    ):
        results = benedict({}, keypath_separator=None)
        results["events", "check_passed"] = True
        results["events", "events_count"] = 0
        results["events", "found_any_events"] = False
        results["events", "recent_warnings"] = []
        results["events", "deployment_has_warnings"] = False
        results["events", "effected_objects"] = []
        results["events", "kubectl_used"] = []
        events = self.get(
            kind="Event",
            kubeconfig=kubeconfig,
            namespace=namespace,
            label_selector=labels,
            field_selector=field_selector,
            target_service=target_service,
            distribution=distribution,
        )
        if events:
            results["events", "found_any_events"] = True
        if "items" in events:
            events = events["items"]
        events = [
            e
            for e in events
            if e["type"] == "Warning"
            and search_name in e["involvedObject"]["name"]
        ]
        if len(events) > 0:
            events = sorted(
                events, key=lambda e: dateutil.parser.parse(e["lastTimestamp"])
            )
            for e in events:
                e = benedict(e, keypath_separator=None)
                object_path = f'{e["involvedObject","kind"]}/{e["involvedObject","name"]}'
                if object_path not in results["events", "effected_objects"]:
                    results["events", "effected_objects"].append(object_path)
                    results["events", "kubectl_used"].append(
                        self.compose_kubectl_command(
                            binary_name=self.get_binary_name(distribution), 
                            verb="get",
                            kind="Event",
                            namespace=namespace,
                            label_selector=labels,
                            field_selector=f'type="Warning",involvedObject.name="{e["involvedObject","name"]}"',
                        )
                    )
            event_counts = [e["count"] for e in events]
            results["events", "events_count"] = sum(event_counts)
            results["events", "deployment_has_warnings"] = True
            results["events", "recent_warnings"] = events[
                -min(number_of_warnings, len(events))
            ]["message"]
            results["events", "check_passed"] = False
        results["events", "kubectl_used"].append(
            self.compose_kubectl_command(
                binary_name=self.get_binary_name(distribution), 
                verb="get",
                kind="Event",
                namespace=namespace,
                label_selector=labels,
                field_selector=field_selector,
            )
        )
        return results

    # TODO: abstract format reports to a well organized mixin that is easy to maintain
    def format_events_report(
        self,
        search_name,
        report_data=benedict({}, keypath_separator=None),
        events_doc_link="https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/",
        mute_suggestions=None,
    ):
        if not mute_suggestions:
            mute_suggestions = K8s.MuteOption.NO.value
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        no_warnings = (
            K8s.ReportSymbol.CHECKMARK.value
            if not report_data["events", "deployment_has_warnings"]
            else K8s.ReportSymbol.X.value
        )
        detected_event_stream = (
            K8s.ReportSymbol.CHECKMARK.value
            if report_data["events", "found_any_events"]
            else K8s.ReportSymbol.X.value
        )
        report_lines.append("Event Stream Checks")
        report_lines.append(
            f"\tEvent Stream under name {search_name} found: {detected_event_stream}"
        )
        if not report_data["events", "found_any_events"]:
            report_lines.append(
                "We couldn't find any events under the name {search_name}. Please check if the configured search name is correct."
            )
        else:
            report_lines.append(
                f"\tNo error events in stream for deployment: {no_warnings}"
            )
            report_lines.append(
                f'\tError Events count: {report_data["events","events_count"]}'
            )
            if len(report_data["events", "recent_warnings"]) > 0:
                if isinstance(report_data["events", "recent_warnings"], list):
                    recent_warnings = ", ".join(
                        report_data["events", "recent_warnings"]
                    )
                else:
                    recent_warnings = report_data["events", "recent_warnings"]
                report_lines.append(
                    f"\tMost recent error Event message(s): {recent_warnings}"
                )
            if len(report_data["events", "effected_objects"]) > 0:
                affected_objects = ", ".join(
                    report_data["events", "effected_objects"]
                )
                report_lines.append(
                    f"\tThe following objects are affected by these warnings: {affected_objects}"
                )
        if report_data["events", "kubectl_used"]:
            report_lines.append("Kubectl Commands Used")
            for kubectl in report_data["events", "kubectl_used"]:
                report_lines.append(f"\t{kubectl}")
        return "\n".join(report_lines)

    def check_resources(
        self,
        kubeconfig,
        namespace,
        search_name,
        labels=None,
        context=None,
        field_selector=None,
        target_service: platform.Service = None,
        distribution: str = "Kubernetes",
    ) -> dict:
        results = benedict({}, keypath_separator=None)

        results["deployment"] = benedict({}, keypath_separator=None)
        results["deployment", "check_passed"] = True
        results["deployment"]["name"] = search_name
        results["deployment", "mem_requests_per_replica"] = 0
        results["deployment", "cpu_requests_per_replica"] = 0
        results["deployment", "mem_limits_per_replica"] = 0
        results["deployment", "cpu_limits_per_replica"] = 0
        results["deployment", "resources_missing"] = False
        results["deployment", "requests_missing"] = False
        results["deployment", "limits_missing"] = False
        results["deployment", "replicas"] = 0
        results["deployment", "mem_requests_sum"] = 0
        results["deployment", "cpu_requests_sum"] = 0
        results["deployment", "mem_limits_sum"] = 0
        results["deployment", "cpu_limits_sum"] = 0
        results["deployment", "kubectl_used"] = []
        deployment = self.get(
            kind="Deployment",
            kubeconfig=kubeconfig,
            name=search_name,
            namespace=namespace,
            label_selector=labels,
            target_service=target_service,
            distribution=distribution,
        )
        if (
            deployment
            and "items" in deployment
            and len(deployment["items"]) > 1
        ):
            raise ValueError(
                "Found more than 1 deployment during deployment troubleshooting, please user more specific search criteria"
            )
        if deployment and "items" in deployment:
            deployment = (
                benedict(deployment["items"][0], keypath_separator=None)
                if "items" in deployment
                else benedict(deployment, keypath_separator=None)
            )
        results["deployment", "deployment_found"] = bool(deployment)
        # TODO: fetch usage values
        if (
            deployment
            and ["spec", "template", "spec", "containers"] in deployment
        ):
            for container in deployment[
                "spec", "template", "spec", "containers"
            ]:
                resources = benedict(
                    container["resources"], keypath_separator=None
                )
                if not resources:
                    results[
                        "deployment", "container_resources", container["name"]
                    ] = None  # none means no resource details found
                    results["deployment", "resources_missing"] = True
                    results["deployment", "requests_missing"] = True
                    results["deployment", "limits_missing"] = True
                else:
                    results[
                        "deployment", "container_resources", container["name"]
                    ] = resources
                    if "limits" in resources:
                        results[
                            "deployment", "mem_limits_per_replica"
                        ] += self.parse_numerical(
                            resources["limits", "memory"]
                        )
                        results[
                            "deployment", "cpu_limits_per_replica"
                        ] += self.parse_numerical(resources["limits", "cpu"])
                    else:
                        results["deployment", "limits_missing"] = True
                    if "requests" in resources:
                        results[
                            "deployment", "mem_requests_per_replica"
                        ] += self.parse_numerical(
                            resources["requests", "memory"]
                        )
                        results[
                            "deployment", "cpu_requests_per_replica"
                        ] += self.parse_numerical(resources["requests", "cpu"])
                    else:
                        results["deployment", "requests_missing"] = True
            results["deployment", "replicas"] = deployment["spec", "replicas"]
            results["deployment", "mem_requests_sum"] = (
                results["deployment", "mem_requests_per_replica"]
                * results["deployment", "replicas"]
            )
            results["deployment", "cpu_requests_sum"] = (
                results["deployment", "cpu_requests_per_replica"]
                * results["deployment", "replicas"]
            )
            results["deployment", "mem_limits_sum"] = (
                results["deployment", "mem_limits_per_replica"]
                * results["deployment", "replicas"]
            )
            results["deployment", "cpu_limits_sum"] = (
                results["deployment", "cpu_limits_per_replica"]
                * results["deployment", "replicas"]
            )
            if (
                results["deployment", "requests_missing"]
                or results["deployment", "limits_missing"]
                or results["deployment", "resources_missing"]
            ):
                results["deployment", "check_passed"] = False
        results["deployment", "kubectl_used"].append(
            self.compose_kubectl_command(
                binary_name=self.get_binary_name(distribution), 
                verb="get",
                kind="Deployment",
                namespace=namespace,
                label_selector=labels,
                field_selector=field_selector,
            )
        )
        return results

    def format_resources_report(
        self,
        search_name,
        report_data=benedict({}, keypath_separator=None),
        resource_doc_link="https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/",
        mute_suggestions=None,
    ):
        if not mute_suggestions:
            mute_suggestions = K8s.MuteOption.NO.value
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        resources_set_symbol = (
            K8s.ReportSymbol.CHECKMARK.value
            if not report_data["deployment", "resources_missing"]
            else K8s.ReportSymbol.X.value
        )
        limits_set_symbol = (
            K8s.ReportSymbol.CHECKMARK.value
            if not report_data["deployment", "limits_missing"]
            else K8s.ReportSymbol.X.value
        )
        requests_set_symbol = (
            K8s.ReportSymbol.CHECKMARK.value
            if not report_data["deployment", "requests_missing"]
            else K8s.ReportSymbol.X.value
        )
        found_symbol = (
            K8s.ReportSymbol.CHECKMARK.value
            if report_data["deployment", "deployment_found"]
            else K8s.ReportSymbol.X.value
        )
        report_lines.append("Deployment Checks")
        report_lines.append(
            f"\tDeployment {search_name} Kubernetes object found: {found_symbol}"
        )
        report_lines.append(
            f"\tContainer resources set: {resources_set_symbol}"
        )
        report_lines.append(f"\tContainer requests set: {requests_set_symbol}")
        report_lines.append(f"\tContainer limits set: {limits_set_symbol}")
        if mute_suggestions == K8s.MuteOption.NO.value and (
            report_data["deployment", "resources_missing"]
            or report_data["deployment", "limits_missing"]
            or report_data["deployment", "requests_missing"]
        ):
            report_lines.append(
                f"\tNot all containers have resources fully set, consider reviewing: {resource_doc_link}"
            )
        else:
            report_lines.append(
                f'\tDeployment {report_data["deployment","name"]} requests {report_data["deployment","mem_requests_sum"]} memory limited to {report_data["deployment","mem_limits_sum"]}'
                f', and requests cpu {report_data["deployment","cpu_requests_sum"]} limited to {report_data["deployment","cpu_limits_sum"]}'
            )
        if report_data["deployment", "kubectl_used"]:
            report_lines.append("Kubectl Commands Used")
            for kubectl in report_data["deployment", "kubectl_used"]:
                report_lines.append(f"\t{kubectl}")
        return "\n".join(report_lines)

    def check_pdb(
        self,
        kubeconfig,
        namespace,
        search_name=None,
        labels=None,
        context=None,
        field_selector=None,
        target_service: platform.Service = None,
        distribution: str = "Kubernetes",
    ):
        # TODO: finish pdbs
        results = benedict({}, keypath_separator=None)
        results["pdbs", "check_passed"] = True
        results["pdbs", "exists"] = False
        results["pdbs", "maps"] = False
        results["pdbs", ""] = False
        results["pdbs", "kubectl_used"] = []
        deployments = self.get(
            kind="Deployment",
            kubeconfig=kubeconfig,
            namespace=namespace,
            label_selector=labels,
            target_service=target_service,
            distribution=distribution,
        )
        if deployments:
            deployments = (
                deployments["items"]
                if "items" in deployments
                else [deployments]
            )
        return results

    def format_pdb_report(
        self,
        search_name,
        report_data=benedict({}, keypath_separator=None),
        pdb_doc_link="https://kubernetes.io/docs/tasks/run-application/configure-pdb/",
        mute_suggestions=None,
    ):
        if not mute_suggestions:
            mute_suggestions = K8s.MuteOption.NO.value
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        # TODO: finish pdb
        # exists
        # maps to deployment
        # not 0
        # not 100%
        # link
        report_lines.append("Pod Disruption Budget Checks")
        if report_data["pdbs", "kubectl_used"]:
            report_lines.append("Kubectl Commands Used")
            for kubectl in report_data["pdbs", "kubectl_used"]:
                report_lines.append(f"\t{kubectl}")
        return "\n".join(report_lines)

    def check_pvc(
        self,
        kubeconfig,
        namespace,
        search_name=None,
        labels=None,
        context=None,
        field_selector=None,
        target_service: platform.Service = None,
        distribution: str = "Kubernetes",
    ):
        results = benedict({}, keypath_separator=None)
        results["pvcs", "check_passed"] = True
        results["pvcs", "deployment_pvcs"] = []
        results["pvcs", "named_pvcs"] = []
        results["pvcs", "labeled_pvcs"] = []
        results["pvcs", "unbound"] = []
        results["pvcs", "dangling"] = []
        results["pvcs", "kubectl_used"] = []
        deployments = self.get(
            kind="Deployment",
            kubeconfig=kubeconfig,
            name=search_name,
            namespace=namespace,
            label_selector=labels,
            target_service=target_service,
            distribution=distribution,
        )
        named_pvcs = self.get(
            kind="PersistentVolumeClaim",
            kubeconfig=kubeconfig,
            name=search_name,
            namespace=namespace,
            label_selector=labels,
            target_service=target_service,
            distribution=distribution,
        )
        labeled_pvcs = self.get(
            kind="PersistentVolumeClaim",
            kubeconfig=kubeconfig,
            namespace=namespace,
            label_selector=labels,
            target_service=target_service,
            distribution=distribution,
        )
        # TODO: fetch pvc usage %
        if deployments:
            deployments = (
                deployments["items"]
                if "items" in deployments
                else [deployments]
            )
            for d in deployments:
                d = benedict(d, keypath_separator=None)
                for v in d["spec", "template", "spec", "volumes"]:
                    v = benedict(v, keypath_separator=None)
                    if ["persistentVolumeClaim", "claimName"] in v:
                        results["pvcs", "deployment_pvcs"].append(
                            v["persistentVolumeClaim", "claimName"]
                        )
        if named_pvcs:
            named_pvcs = (
                named_pvcs["items"] if "items" in named_pvcs else [named_pvcs]
            )
            for pvc in named_pvcs:
                pvc = benedict(pvc, keypath_separator=None)
                results["pvcs", "named_pvcs"].append(pvc["metadata", "name"])
                if ["status", "phase"] in pvc and pvc[
                    "status", "phase"
                ] != "Bound":
                    results["pvcs", "unbound"].append(pvc["metadata", "name"])
        if labeled_pvcs:
            labeled_pvcs = (
                labeled_pvcs["items"]
                if "items" in labeled_pvcs
                else [labeled_pvcs]
            )
            for pvc in labeled_pvcs:
                pvc = benedict(pvc, keypath_separator=None)
                results["pvcs", "labeled_pvcs"].append(pvc["metadata", "name"])
                if ["status", "phase"] in pvc and pvc[
                    "status", "phase"
                ] != "Bound":
                    results["pvcs", "unbound"].append(pvc["metadata", "name"])
                if (
                    ["status", "phase"] in pvc
                    and pvc["status", "phase"] != "Bound"
                    and pvc["metadata", "name"]
                    not in results["pvcs", "deployment_pvcs"]
                ):
                    results["pvcs", "dangling"].append(pvc["metadata", "name"])
        results["pvcs", "kubectl_used"].append(
            self.compose_kubectl_command(
                binary_name=self.get_binary_name(distribution),
                verb="get",
                kind="pvc",
                namespace=namespace,
                label_selector=labels,
            )
        )
        results["pvcs", "kubectl_used"].append(
            self.compose_kubectl_command(
                binary_name=self.get_binary_name(distribution),
                verb="get",
                kind="Deployment",
                name=search_name,
                namespace=namespace,
                label_selector=labels,
            )
        )
        return results

    def format_pvc_report(
        self,
        search_name,
        report_data=benedict({}, keypath_separator=None),
        mute_suggestions=None,
    ):
        if not mute_suggestions:
            mute_suggestions = K8s.MuteOption.NO.value
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        no_dangling = (
            K8s.ReportSymbol.CHECKMARK.value
            if not len(report_data["pvcs", "dangling"]) > 0
            else K8s.ReportSymbol.X.value
        )
        no_unbound = (
            K8s.ReportSymbol.CHECKMARK.value
            if not len(report_data["pvcs", "unbound"]) > 0
            else K8s.ReportSymbol.X.value
        )
        report_lines.append("Persistent Volume Claim Checks")
        report_lines.append(f"\tNo dangling volumes detected: {no_dangling}")
        report_lines.append(f"\tNo unbound volumes detected: {no_unbound}")
        if report_data["pvcs", "kubectl_used"]:
            report_lines.append("Kubectl Commands Used")
            for kubectl in report_data["pvcs", "kubectl_used"]:
                report_lines.append(f"\t{kubectl}")
        return "\n".join(report_lines)

    def check_pods(
        self,
        kubeconfig,
        namespace,
        search_name=None,
        labels=None,
        context=None,
        field_selector=None,
        target_service: platform.Service = None,
        distribution: str = "Kubernetes",
    ):
        results = benedict({}, keypath_separator=None)
        results["pods", "check_passed"] = True
        results["pods", "liveness_checks"] = True
        results["pods", "readiness_checks"] = True
        results["pods", "restart_count"] = 0
        results["pods", "pods_healthy"] = True
        results["pods", "pod_list"] = []
        results["pods", "container_statuses"] = []
        results["pods", "containers_healthy"] = True
        results["pods", "kubectl_used"] = []
        temp_pod_names = []
        pods = self.get(
            kind="Pod",
            kubeconfig=kubeconfig,
            namespace=namespace,
            label_selector=labels,
            target_service=target_service,
            distribution=distribution,
        )
        if pods:
            pods = pods["items"] if "items" in pods else [pods]
            if search_name:
                pods = [
                    p for p in pods if search_name in p["metadata"]["name"]
                ]
            for pod in pods:
                pod = benedict(pod, keypath_separator=None)
                if (
                    pod["status", "phase"] == "Failed"
                    or pod["status", "phase"] == "Unknown"
                ):
                    results["pods", "pods_healthy"] = False
                    temp_pod_names.append(pod["metadata", "name"])
                if ["spec", "containers"] in pod:
                    for container in pod["spec", "containers"]:
                        if "readinessProbe" not in container:
                            results["pods", "readiness_checks"] = False
                            temp_pod_names.append(pod["metadata", "name"])
                        if "livenessProbe" not in container:
                            results["pods", "liveness_checks"] = False
                            temp_pod_names.append(pod["metadata", "name"])
                    if ["status", "containerStatuses"] in pod:
                        for c_status in pod["status", "containerStatuses"]:
                            c_status = benedict(
                                c_status, keypath_separator=None
                            )
                            if (
                                c_status["ready"] == "False"
                                or c_status["started"] == "False"
                            ):
                                results["pods", "containers_healthy"] = False
                                temp_pod_names.append(pod["metadata", "name"])
                            if ["state", "waiting"] in c_status or [
                                "state",
                                "terminated",
                            ] in c_status:
                                results["pods", "containers_healthy"] = False
                                results["pods", "container_statuses"].append(
                                    str(c_status["state"])
                                )
                                temp_pod_names.append(pod["metadata", "name"])
                            results["pods", "restart_count"] += c_status[
                                "restartCount"
                            ]
        for pod_name in temp_pod_names:
            pod_name = f"Pod/{pod_name}"
            if pod_name not in results["pods", "pod_list"]:
                results["pods", "pod_list"].append(pod_name)
        results["pods", "kubectl_used"].append(
            self.compose_kubectl_command(
                binary_name=self.get_binary_name(distribution),
                verb="get",
                kind="Pod",
                namespace=namespace,
                label_selector=labels,
            )
        )
        results["pods", "check_passed"] = (
            results["pods", "pods_healthy"]
            and results["pods", "containers_healthy"]
            and results["pods", "liveness_checks"]
            and results["pods", "readiness_checks"]
        )
        return results

    def format_pods_report(
        self,
        search_name,
        report_data=benedict({}, keypath_separator=None),
        mute_suggestions=None,
    ):
        if not mute_suggestions:
            mute_suggestions = K8s.MuteOption.NO.value
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        pods_healthy = (
            K8s.ReportSymbol.CHECKMARK.value
            if report_data["pods", "pods_healthy"]
            else K8s.ReportSymbol.X.value
        )
        live_present = (
            K8s.ReportSymbol.CHECKMARK.value
            if report_data["pods", "liveness_checks"]
            else K8s.ReportSymbol.X.value
        )
        ready_present = (
            K8s.ReportSymbol.CHECKMARK.value
            if report_data["pods", "readiness_checks"]
            else K8s.ReportSymbol.X.value
        )
        containers_healthy = (
            K8s.ReportSymbol.CHECKMARK.value
            if report_data["pods", "containers_healthy"]
            else K8s.ReportSymbol.X.value
        )
        report_lines.append("Pod Checks")
        report_lines.append(f"\tPod(s) detected healthy: {pods_healthy}")
        report_lines.append(f"\tAll pods have liveness checks: {live_present}")
        report_lines.append(
            f"\tAll pods have readiness checks: {ready_present}"
        )
        report_lines.append(
            f"\tContainer(s) across pod(s) healthy: {containers_healthy}"
        )
        report_lines.append(
            f'\tTotal Restart Count: {report_data["pods","restart_count"]}'
        )
        if report_data["pods", "container_statuses"]:
            container_statuses = ", ".join(
                report_data["pods", "container_statuses"]
            )
            report_lines.append(
                f"\tContainer Status List: {container_statuses}"
            )
        if (
            not report_data["pods", "pods_healthy"]
            and report_data["pods", "pod_list"]
        ):
            pod_list = ", ".join(report_data["pods", "pod_list"])
            report_lines.append(f"\tUnhealthy Pod List: {pod_list}")
        if report_data["pods", "kubectl_used"]:
            report_lines.append("Kubectl Commands Used")
            for kubectl in report_data["pods", "kubectl_used"]:
                report_lines.append(f"\t{kubectl}")
        return "\n".join(report_lines)

    def check_networking(
        self,
        kubeconfig,
        namespace,
        search_name=None,
        labels=None,
        context=None,
        field_selector=None,
        target_service: platform.Service = None,
        distribution: str = "Kubernetes",
    ):
        results = benedict({}, keypath_separator=None)
        results["network", "check_passed"] = True
        results["network", "service_found"] = True
        results["network", "service_selector_valid"] = True
        # TODO: add ingress mapping check
        # results["network","has_ingress"] = True
        # results["network","ingress_maps_service"] = True
        results["network", "kubectl_used"] = []
        services = self.get(
            kind="Service",
            kubeconfig=kubeconfig,
            namespace=namespace,
            label_selector=labels,
            target_service=target_service,
            distribution=distribution,
        )
        # ingresses = self.get(
        #     kind="Ingress",
        #     kubeconfig=kubeconfig,
        #     namespace=namespace,
        #     label_selector=labels,
        # )
        if services:
            services = services["items"] if "items" in services else [services]
            if services:
                if search_name:
                    services = [
                        svc
                        for svc in services
                        if search_name in svc["metadata"]["name"]
                    ]
                for svc in services:
                    svc = benedict(svc, keypath_separator=None)
                    selector = svc["spec", "selector"]
                    for k, v in selector.items():
                        pods_selected = self.get(
                            kind="Pod",
                            kubeconfig=kubeconfig,
                            namespace=namespace,
                            label_selector=f"{k}={v}",
                            target_service=target_service,
                            distribution=distribution,
                        )
                        if not pods_selected:
                            results[
                                "network", "service_selector_valid"
                            ] = False
            else:
                results["network", "service_found"] = False
                results["network", "service_selector_valid"] = False
        results["network", "kubectl_used"].append(
            self.compose_kubectl_command(
                binary_name=self.get_binary_name(distribution),
                verb="get",
                kind="Service",
                namespace=namespace,
                label_selector=labels,
            )
        )
        results["network", "check_passed"] = (
            results["network", "service_found"]
            and results["network", "service_selector_valid"]
        )
        return results

    def format_networking_report(
        self,
        search_name,
        report_data=benedict({}, keypath_separator=None),
        mute_suggestions=None,
    ):
        if not mute_suggestions:
            mute_suggestions = K8s.MuteOption.NO.value
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        svc_found = (
            K8s.ReportSymbol.CHECKMARK.value
            if report_data["network", "service_found"]
            else K8s.ReportSymbol.X.value
        )
        svc_selector_valid = (
            K8s.ReportSymbol.CHECKMARK.value
            if report_data["network", "service_selector_valid"]
            else K8s.ReportSymbol.X.value
        )
        report_lines.append("Networking Checks")
        report_lines.append(f"\tService found: {svc_found}")
        report_lines.append(
            f"\tService selector is valid: {svc_selector_valid}"
        )
        if report_data["network", "kubectl_used"]:
            report_lines.append("Kubectl Commands Used")
            for kubectl in report_data["network", "kubectl_used"]:
                report_lines.append(f"\t{kubectl}")
        return "\n".join(report_lines)

    def check_security_context(self):
        pass

    def check_container_service_account(self):
        pass

    def format_report(self, checklist: dict):
        pass

    def parse_numerical(self, numeric_str: str):
        return float(
            "".join(i for i in numeric_str if i.isdigit() or i in [".", "-"])
        )

    def compose_kubectl_command(
        self,
        kind: str,
        name: str = None,
        verb: str = "",
        verb_flags: str = "",
        label_selector: str = None,
        field_selector: str = None,
        context: str = None,
        namespace: str = None,
        output_format="yaml",
        binary_name: str="kubectl",
        **kwargs,
    ):
        command = []
        command.append(f"{binary_name}")
        if context:
            command.append(f"--context {context}")
        if namespace:
            command.append(f"--namespace {namespace}")

        if verb and verb_flags:
            command.append(f"{verb} {verb_flags}")
        elif verb:
            command.append(f"{verb}")

        if label_selector:
            command.append(f"--selector {label_selector}")

        if kind and name and not label_selector:
            command.append(f"{kind}/{name}")
        elif kind:
            command.append(f"{kind}")

        if field_selector:
            command.append(f"--field-selector {field_selector}")

        if output_format:
            command.append(f"-o{output_format}")
        return " ".join(command)

    # TODO: move these to generic helpers
    def stdout_to_grid(self, stdout):
        stdout_grid = []
        for line in stdout.splitlines():
            stdout_grid.append(line.split())
        return stdout_grid

    def get_stdout_grid_column(self, stdout_grid, index: int):
        """
        Helper function to return a column as a list from the stdout lists of a kubectl command
        """
        result_column = []
        for row in stdout_grid:
            result_column.append(row[index])
        return result_column

    def remove_units(
        self,
        data_points,
    ):
        """
        Iterates over list and removes units
        - ``data_points`` list of string values containing numerical value substrings

        Examples:
        | RW.Kubectl.Remove Units  |   ${str_list}
        Return Value:
        | List of floats |
        """
        cleaned = []
        for d in data_points:
            numerical = float(
                "".join(i for i in d if i.isdigit() or i in [".", "-"])
            )
            cleaned.append(numerical)
        return cleaned

    def top_aggregate(self, method: str, column: list):
        if method == "Max":
            return max(column)
        elif method == "Average":
            return sum(column) / len(column)
        elif method == "Minimum":
            return min(column)
        elif method == "Sum":
            return sum(column)
