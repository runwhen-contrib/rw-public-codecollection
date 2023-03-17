import re, kubernetes, yaml, logging, json
from struct import unpack
import dateutil.parser
from benedict import benedict
from datetime import datetime, timezone
from dateutil.relativedelta import relativedelta
from collections import defaultdict
from typing import Optional, Union
from RW import platform
from enum import Enum
from .k8s_connection import K8sConnection
from .deployment_tasks_mixin import DeploymentTasksMixin
from .event_tasks_mixin import EventTasksMixin
from .pvc_tasks_mixin import PvcTasksMixin
from .pod_tasks_mixin import PodTasksMixin
from .pdb_tasks_mixin import PdbTasksMixin
from .network_tasks_mixin import NetworkTasksMixin
from .statefulset_tasks_mixin import StatefuletTasksMixin
from .job_tasks_mixin import JobTasksMixin
from .daemonset_tasks_mixin import DaemonsetTasksMixin
from .k8sutils import K8sUtils
from RW.Utils.utils import search_json
from RW.Utils.utils import dict_to_yaml
from RW.Utils.utils import from_json
from RW.Utils.utils import yaml_to_dict
from RW.Utils.utils import stdout_to_list
from RW.Utils.Check import Check
from RW.Utils.utils import SYMBOL_GREEN_CHECKMARK, SYMBOL_RED_X
from RW.Utils.utils import parse_timedelta

from robot.libraries.BuiltIn import BuiltIn

logger = logging.getLogger(__name__)


class NamespaceTasksMixin(
    K8sConnection,
    DeploymentTasksMixin,
    EventTasksMixin,
    PvcTasksMixin,
    PodTasksMixin,
    PdbTasksMixin,
    NetworkTasksMixin,
    JobTasksMixin,
    DaemonsetTasksMixin,
    StatefuletTasksMixin,
):
    def get_object_names(self, k8s_items, distinct_values: bool = True) -> list:
        object_names: list = []
        if "items" in k8s_items:
            k8s_items = k8s_items["items"]
        for item in k8s_items:
            item: benedict = benedict(item, keypath_separator=None)
            kind: str = item["kind"]
            name: str = item["metadata", "name"]
            object_name: str = f"{kind}/{name}"
            if distinct_values is True and object_name not in object_names:
                object_names.append(object_name)
            else:
                object_names.append(object_name)
        return object_names

    def get_objects_by_name(
        self, names: list, namespace: str, context: str, target_service: platform.Service, kubeconfig: platform.Secret
    ) -> list:
        list_of_k8s_objects: list = []
        for name in names:
            stdout = self.shell(
                cmd=f"kubectl get {name} --context={context} --namespace={namespace} -o yaml",
                target_service=target_service,
                kubeconfig=kubeconfig,
            )
            if stdout:
                k8s_object = yaml_to_dict(stdout)
                list_of_k8s_objects.append(k8s_object)
        return list_of_k8s_objects

    def search_namespace_objects_for_string(self, k8s_items, search_string: str) -> list:
        found_in_objects: list = []
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
        context: str,
        namespace: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
    ) -> dict:
        """*DEPRECATED*"""
        troubleshoot_results = {}
        if object_name.startswith("event.events.k8s.io/") or object_name.startswith("event/"):
            pass  # TODO: determine useful event troubleshoot data in this context
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
        context: str,
        namespace: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
    ) -> str:
        """*DEPRECATED*"""
        checks: list(Checks) = []
        checks.append(
            Check(
                title=f"Found and applied troubleshooting for the following objects in namespace: {namespace}:\n",
            )
        )
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
                checks.append(
                    Check(
                        title=f"\tObject {k8s_object_name} troubleshoot pass/fail status:",
                        symbol=bool(status),
                    )
                )
        return "\n".join([str(c) for c in checks])

    def check_namespace_errors(
        self,
        context: str,
        namespace: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
        error_pattern: str = "(Error|Exception)",
    ) -> str:
        checks: list(Checks) = []
        stdout: str = self.shell(
            f"{binary_name} get Events --context={context} --namespace={namespace} -o yaml", target_service, kubeconfig
        )
        events: dict = yaml_to_dict(stdout)
        if "items" in events:
            events_count = len(events["items"])
        else:
            events_count = len(events)
        events_involved_objects: list = self.get_involved_object_name_list(events)
        stdout: str = self.shell(
            f"{binary_name} get pods --context={context} --namespace={namespace} --field-selector=status.phase==Running -o yaml",
            target_service,
            kubeconfig,
        )
        pods: dict = yaml_to_dict(stdout)
        pod_object_names: list(str) = self.get_object_names(pods)
        pod_log_mapping: dict = {}
        for pod_object_name in pod_object_names:
            cmd: str = f'{binary_name} logs --context={context} --namespace={namespace} {pod_object_name} --tail=100 | grep -E -i "{error_pattern}"'
            try:
                stdout = self.shell(cmd, target_service, kubeconfig)
                pod_log_mapping[pod_object_name] = stdout
            except:
                logger.warning(f"Unable to fetch logs from pod {pod_object_name} with command: {cmd}")
        pods_with_error_logs: list = []
        for pod_object_name, pod_logs in pod_log_mapping.items():
            if pod_logs:
                pods_with_error_logs.append(pod_object_name)
        checks.append(
            Check(
                title=f"No non-info events found in namespace {namespace}",
                symbol=bool(events_count == 0),
            )
        )
        if events_count > 0:
            events_involved_objects = "\n\t\t".join(events_involved_objects)
            checks.append(
                Check(
                    title=f"Total non-info events found in namespace: {namespace}: ",
                    value=f"{events_count}",
                )
            )
            checks.append(
                Check(
                    title=f"Objects with non-info events in namespace: {namespace}:\n",
                    value=f"""{events_involved_objects}""",
                )
            )
        checks.append(
            Check(
                title=f"Pod workloads in namespace {namespace} do not have errors in recent logs: ",
                symbol=bool(len(pods_with_error_logs) == 0),
            )
        )
        if len(pods_with_error_logs) > 0:
            pods_with_error_logs: str = "\n\t\t".join(pods_with_error_logs)
            checks.append(
                Check(
                    title=f"Running pod workloads with error entries in their logs:",
                    value=f"{pods_with_error_logs}",
                )
            )
        return "\n".join([str(c) for c in checks])

    def get_event_count(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        event_pattern: str = "*",
        binary_name: str = "kubectl",
        event_type: str = "Warning",
        event_age: str = "30m",
    ) -> int:

        events_stdout: str = self.shell(
            cmd=f'{binary_name} get events -n {namespace} --context {context} --no-headers --field-selector type={event_type} | grep -E -i "{event_pattern}"',
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        if events_stdout:
            event_rows: list = stdout_to_list(events_stdout, delimiter="\n")
            return len(event_rows)
        else:
            return 0

    def count_events_by_age_and_type(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
        event_age: str = None,
        event_type: str = "Warning",
    ) -> float:
        # K8s Event Ref: https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/
        search_time = K8sUtils.convert_age_to_search_time(age=event_age)
        search_filter = f"type==`{event_type}` && lastTimestamp >= `{search_time}`"
        if "ALL" in namespace:
            cmd = f"{binary_name} get events --all-namespaces --context {context} -o json"
        elif "," in namespace:
            ## Combine csv into jmespath OR query
            # e.g. items[?type==`Normal` && lastTimestamp >= `2023-02-13T12:25:46Z` && (metadata.namespace == `gmp-system` || metadata.namespace == `flux-system`) ]
            cmd = f"{binary_name} get events --all-namespaces --context {context} -o json"
            namespace_search_string = K8sUtils.jmespath_namespace_search_string(namespaces=namespace)
            search_filter = f"({namespace_search_string}) && type==`{event_type}` && lastTimestamp >= `{search_time}`"
        else:
            cmd = f"{binary_name} get events -n {namespace} --context {context} -o json"
        events_json: str = self.shell(
            cmd=cmd,
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        return K8sUtils.convert_to_metric(data=events_json, search_filter=search_filter, calculation_field="Count")

    def count_container_restarts_by_age(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
        container_restart_age: str = None,
    ) -> float:
        search_time = K8sUtils.convert_age_to_search_time(age=container_restart_age)
        search_filter = (
            f"status.containerStatuses[?restartCount>`0` && lastState.terminated.finishedAt >= `{search_time}`]"
        )
        if "ALL" in namespace:
            cmd = f"{binary_name} get pods --all-namespaces --context {context} -o json"
        elif "," in namespace:
            ## Combine csv into jmespath OR query
            cmd = f"{binary_name} get pods --all-namespaces --context {context} -o json"
            namespace_search_string = K8sUtils.jmespath_namespace_search_string(namespaces=namespace)
            search_filter = f"({namespace_search_string}) && status.containerStatuses[?restartCount>`0` && lastState.terminated.finishedAt >= `{search_time}`]"
        else:
            cmd = f"{binary_name} get pods -n {namespace} --context {context} -o json"
        events_json: str = self.shell(
            cmd=cmd,
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        return K8sUtils.convert_to_metric(data=events_json, search_filter=search_filter, calculation_field="Count")

    def count_notready_pods(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
    ) -> float:
        search_filter = f"status.conditions[?type==`Ready` && status!=`True` && reason!=`PodCompleted`]"
        if "ALL" in namespace:
            cmd = f"{binary_name} get pods --all-namespaces --context {context} -o json"
        elif "," in namespace:
            ## Combine csv into jmespath OR query
            cmd = f"{binary_name} get pods --all-namespaces --context {context} -o json"
            namespace_search_string = K8sUtils.jmespath_namespace_search_string(namespaces=namespace)
            search_filter = f"({namespace_search_string}) && status.conditions[?type==`Ready` && status!=`True` && reason!=`PodCompleted`]"
        else:
            cmd = f"{binary_name} get pods -n {namespace} --context {context} -o json"
        events_json: str = self.shell(
            cmd=cmd,
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        return K8sUtils.convert_to_metric(data=events_json, search_filter=search_filter, calculation_field="Count")

    def get_custom_resources(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
        crd_filter: str = "",
    ) -> list:
        """Takes in a search string to search for available custom resource definition types (searching metadata.name only). Accepts a namespace, and a context and returns any custom resource names that match the filter as a list.

        Args:
            :namespace str: The namespace to query for results.
            :context str: The kubnerets context to use, as listed in the kubeconfig secret.
            :crd_filter str: A string that filters which CRDs to search for.
            :kubeconfig paltform.Secret: A kubeconfig that provides access to the necessary resources.
            :target_service platform.Service: Which service to use (typically kubectl)
            :binary_name str:  The binary to use. Typically kubectl, but could also be oc, or another k8s distribution.
            :return list: A list of custom resource definitions that matched the filter.

        """
        ## TODO Expand search capabilities to look through annotations or labels
        search_filter = f"items[?contains(metadata.name, `{crd_filter}`)].metadata.name"
        cmd = f"{binary_name} get crd --context {context} -o json"
        crd_list: str = self.shell(
            cmd=cmd,
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        # Log search filter - keep this so that useres can validate their patterns with jmespath
        BuiltIn().run_keyword("Log", search_filter)
        crd_name_list = search_json(data=json.loads(crd_list), pattern=search_filter)
        return crd_name_list

    def describe_custom_resources(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
        custom_resources: list = "",
    ) -> str:
        """Takes in a list of custom resources, a namespace, and a context and returns the output of kubectl describe for all matching objects.

        Args:
            :namespace str: The namespace to query for results.
            :context str: The kubnerets context to use, as listed in the kubeconfig secret.
            :custom_resources list: A list of custom resources to search for.
            :kubeconfig paltform.Secret: A kubeconfig that provides access to the necessary resources.
            :target_service platform.Service: Which service to use (typically kubectl)
            :binary_name str:  The binary to use. Typically kubectl, but could also be oc, or another k8s distribution.
            :return str: The string output of the query results.

        """
        ## TODO add filtering / search capability
        output: str = ""
        for resource in custom_resources:
            cmd = f"{binary_name} describe {resource} -n {namespace} --context {context}"
            crd_list: str = self.shell(
                cmd=cmd,
                target_service=target_service,
                kubeconfig=kubeconfig,
            )
            output = crd_list + output
        return output

    def fetch_pod_logs_and_events_by_label(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
        resource_labels: str = "",
        log_lines: int = 100,
    ) -> str:
        """Takes in a list of labels, a namespace, and a context and returns the logs and events for each pod that matches the label.

        Args:
            :namespace str: The namespace to query for results.
            :context str: The kubnerets context to use, as listed in the kubeconfig secret.
            :custom_resources list: A list of custom resources to search for.
            :kubeconfig paltform.Secret: A kubeconfig that provides access to the necessary resources.
            :target_service platform.Service: Which service to use (typically kubectl)
            :binary_name str:  The binary to use. Typically kubectl, but could also be oc, or another k8s distribution.
            :resources_labels str: A list of labels to select pods with.
            :log lines int: The number of log lines to include for each pod. Defaults to 100, -1 includes all pod logs.
            :return str: The stdout of the query as a string.

        """
        output: str = ""
        pod_names = self.fetch_pod_names_by_label(
            namespace, context, kubeconfig, target_service, binary_name, resource_labels
        )
        for pod_name in pod_names:
            cmd = (
                f"{binary_name} logs {pod_name} --tail={log_lines} --all-containers -n {namespace} --context {context}"
            )
            log_output: str = self.shell(
                cmd=cmd,
                target_service=target_service,
                kubeconfig=kubeconfig,
            )
            output = f"POD LOGS: {pod_name}\n--------\n{log_output}\n--------\n{output}"
            cmd = f"{binary_name} get events --field-selector involvedObject.name={pod_name} -n {namespace} --context {context}"
            event_output: str = self.shell(
                cmd=cmd,
                target_service=target_service,
                kubeconfig=kubeconfig,
            )
            output = f"POD EVENTS: {pod_name}\n--------\n{event_output}\n--------\n{output}"
        return output

    def fetch_pod_names_by_label(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
        resource_labels: str = "",
    ) -> list():
        """Takes in a list labels a list of pod names.

        Args:
            :namespace str: The namespace to query for results.
            :context str: The kubnerets context to use, as listed in the kubeconfig secret.
            :kubeconfig paltform.Secret: A kubeconfig that provides access to the necessary resources.
            :target_service platform.Service: Which service to use (typically kubectl)
            :binary_name str:  The binary to use. Typically kubectl, but could also be oc, or another k8s distribution.
            :resources_labels str: A list of labels to select pods with.
            :return list: Returns a list of pod names that match the label selectors.

        """
        cmd = f"{binary_name} get pods -l {resource_labels} -n {namespace} --context {context} -o json"
        pod_details: str = self.shell(
            cmd=cmd,
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        pod_names = search_json(data=json.loads(pod_details), pattern="items[].metadata.name")
        return pod_names

    def fetch_pod_resource_utilization_by_label(
        self,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
        resource_labels: str = "",
    ) -> str:
        """Takes in a list labels and returns the output of kubectl top for each container within each pod.

        Args:
            :namespace str: The namespace to query for results.
            :context str: The kubnerets context to use, as listed in the kubeconfig secret.
            :kubeconfig paltform.Secret: A kubeconfig that provides access to the necessary resources.
            :target_service platform.Service: Which service to use (typically kubectl)
            :binary_name str:  The binary to use. Typically kubectl, but could also be oc, or another k8s distribution.
            :resources_labels str: A list of labels to select pods with.
            :return str: The stdout of the query as a string.

        """
        output: str = ""
        pod_names = self.fetch_pod_names_by_label(
            namespace, context, kubeconfig, target_service, binary_name, resource_labels
        )
        for pod_name in pod_names:
            cmd = f"{binary_name} top pod {pod_name} --containers -n {namespace} --context {context}"
            top_output: str = self.shell(
                cmd=cmd,
                target_service=target_service,
                kubeconfig=kubeconfig,
            )
            output = f"POD NAME: {pod_name}\n--------\n{top_output}\n--------\n${output}"
        return output

    @staticmethod
    def triage_namespace(
        resource_kinds: str,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
    ) -> str:
        """Pulls json for a list of resources in a given namespace. A suite of checks are performed on the json
        and a report is generated

        Args:
            :resource_kinds str: a csv of what resources to query for json data.
            :namespace str: The namespace to query for results.
            :context str: The kubnerets context to use, as listed in the kubeconfig secret.
            :kubeconfig paltform.Secret: A kubeconfig that provides access to the necessary resources.
            :target_service platform.Service: Which service to use (typically kubectl)
            :binary_name str:  The binary to use. Typically kubectl, but could also be oc, or another k8s distribution.
            :return str: a report summarizing the traced errors.
        """
        namespace_objects: Union[dict, list, str] = K8sConnection.shell(
            cmd=f"{binary_name} get {resource_kinds} --context={context} --namespace={namespace} -o json",
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        if isinstance(namespace_objects, str):
            namespace_objects = from_json(namespace_objects)
        if "items" in namespace_objects:
            namespace_objects = namespace_objects["items"]
        all_passed: bool = True
        # stores various info to template into the report
        report_fragments: dict = {
            "deployment_replicas_status": f"Passed {SYMBOL_GREEN_CHECKMARK}",
            "deployment_replica_output": "",
            "deployment_checked": 0,
            "deployment_failed": 0,
            "daemonset_replicas_status": f"Passed {SYMBOL_GREEN_CHECKMARK}",
            "daemonsets_replicas_output": "",
            "daemonsets_checked": 0,
            "daemonsets_failed": 0,
            "statefulset_replicas_status": f"Passed {SYMBOL_GREEN_CHECKMARK}",
            "statefulsets_replica_output": "",
            "statefulsets_checked": 0,
            "statefulsets_failed": 0,
        }
        for ns_obj in namespace_objects:
            try:
                ns_obj_name = search_json(ns_obj, "metadata.name")
                ns_obj_kind = ns_obj["kind"]
                # surface level deployment check
                if ns_obj_kind == "Deployment":
                    report_fragments["deployment_checked"] += 1
                    if not report_fragments["deployment_replicas_status"]:
                        report_fragments["deployment_replicas_status"] = f"Passed {SYMBOL_GREEN_CHECKMARK}"
                    ready_replicas = search_json(ns_obj, "status.readyReplicas")
                    ready_replicas = 0 if not isinstance(ready_replicas, int) else ready_replicas
                    replicas = search_json(ns_obj, "status.replicas")
                    if ready_replicas < replicas:
                        report_fragments["deployment_replicas_status"] = f"Failed {SYMBOL_RED_X}"
                        report_fragments["deployment_failed"] += 1
                        if not report_fragments["deployment_replica_output"]:
                            report_fragments["deployment_replica_output"] = "\tUnhealthy Deployment Names:\n"
                        report_fragments["deployment_replica_output"] += f"\t\t\t{ns_obj_kind}/{ns_obj_name}"
                        report_fragments[
                            "deployment_replica_output"
                        ] += f" - for more info run: {binary_name} describe {ns_obj_kind}/{ns_obj_name} --context={context} --namespace={namespace} \n"
                        all_passed = False
                # surface level daemonset check
                elif ns_obj_kind == "Daemonset":
                    report_fragments["daemonsets_checked"] += 1
                    if not report_fragments["daemonset_replicas_status"]:
                        report_fragments["daemonset_replicas_status"] = f"Passed {SYMBOL_GREEN_CHECKMARK}"
                    curr_scheduled = search_json(ns_obj, "status.currentNumberScheduled")
                    num_available = search_json(ns_obj, "status.number_available")
                    mischeduled = search_json(ns_obj, "status.numberMisscheduled")
                    curr_scheduled = 0 if not isinstance(curr_scheduled, int) else curr_scheduled
                    num_available = 0 if not isinstance(num_available, int) else num_available
                    mischeduled = 0 if not isinstance(mischeduled, int) else mischeduled
                    if mischeduled > 0 or curr_scheduled != num_available:
                        report_fragments["daemonset_replicas_status"] = f"Failed {SYMBOL_RED_X}"
                        report_fragments["daemonsets_failed"] += 1
                        if not report_fragments["daemonsets_replicas_output"]:
                            report_fragments["daemonsets_replicas_output"] = "\tUnhealthy Daemonset Names:\n"
                        report_fragments["daemonsets_replicas_output"] += f"\t\t\t{ns_obj_kind}/{ns_obj_name}"
                        report_fragments[
                            "daemonsets_replicas_output"
                        ] += f" - for more info run: {binary_name} describe {ns_obj_kind}/{ns_obj_name} --context={context} --namespace={namespace} \n"
                        all_passed = False
                # Surface level statefulset check
                elif ns_obj_kind == "StatefulSet":
                    report_fragments["statefulsets_checked"] += 1
                    if not report_fragments["statefulset_replicas_status"]:
                        report_fragments["statefulset_replicas_status"] = f"Passed {SYMBOL_GREEN_CHECKMARK}"
                    replicas = search_json(ns_obj, "status.replicas")
                    ready_replicas = search_json(ns_obj, "status.readyReplicas")
                    replicas = 0 if not isinstance(replicas, int) else replicas
                    ready_replicas = 0 if not isinstance(ready_replicas, int) else ready_replicas
                    if ready_replicas < replicas:
                        report_fragments["statefulset_replicas_status"] = f"Failed {SYMBOL_RED_X}"
                        report_fragments["statefulsets_failed"] += 1
                        if not report_fragments["statefulsets_replica_output"]:
                            report_fragments["statefulsets_replica_output"] = "\tUnhealthy StatefulSet Names:\n"
                        report_fragments["statefulsets_replica_output"] += f"\t\t\t{ns_obj_kind}/{ns_obj_name}"
                        report_fragments[
                            "statefulsets_replica_output"
                        ] += f" - for more info run: {binary_name} describe {ns_obj_kind}/{ns_obj_name} --context={context} --namespace={namespace} \n"
                        all_passed = False
                # TODO: hpas, ingress, cj
            except Exception as e:
                logger.warning(f"Encountered {e} during troubleshooting on object {ns_obj}, continuing on")
        report_fragments["status"] = f"Passed {SYMBOL_GREEN_CHECKMARK}" if all_passed else f"Failed {SYMBOL_RED_X}"
        report: str = """
Triage Namespace Summary: {status}
    Deployments found with issues: {deployment_failed}/{deployment_checked}
    Deployments have the expected number of replicas: {deployment_replicas_status}
        {deployment_replica_output}
    Daemonsets found with issues: {daemonsets_failed}/{daemonsets_checked}
    Daemonsets have the expected number of replicas: {daemonset_replicas_status}
        {daemonsets_replicas_output}
    StatefulSet found with issues: {statefulsets_failed}/{statefulsets_checked}
    StatefulSet have the expected number of replicas: {statefulset_replicas_status}
        {statefulsets_replica_output}
        """.format(
            **report_fragments
        )
        return report

    @staticmethod
    def trace_namespace_errors(
        context: str,
        namespace: str,
        target_service: platform.Service,
        kubeconfig: platform.Secret,
        error_pattern: str = "(Error|Exception)",
        event_age: str = "30m",
        binary_name: str = "kubectl",
        max_events_displayed: int = 5,
    ):
        """fetches events and filters them based on age, for valid events if they have an associated pod
        it will be checked for error entries in the last 20 lines of pod logs.

        Args:
            :context str: The kubnerets context to use, as listed in the kubeconfig secret.
            :namespace str: The namespace to query for results.
            :target_service platform.Service: Which service to use (typically kubectl)
            :kubeconfig paltform.Secret: A kubeconfig that provides access to the necessary resources.
            :error_pattern str: the string used to grep for error logs in pods.
            :event_age str: how old to consider for valid events to trace.
            :binary_name str:  The binary to use. Typically kubectl, but could also be oc, or another k8s distribution.
            :return str: a report summarizing the traced errors.

        """
        all_passed: bool = True
        # get events and collect involved pods
        events_cmd: str = f"{binary_name} get Events --context={context} --namespace={namespace} --field-selector=type!=Normal --sort-by=lastTimestamp -o json"
        events: str = K8sConnection.shell(events_cmd, target_service, kubeconfig)
        events: dict = from_json(events)
        error_events_summary: list = []
        if "items" in events:
            events = events["items"]
        events_involved_pods: list = []
        filtered_events: list = []
        event_age_gap: datetime.timedelta = parse_timedelta(event_age)
        start_time = datetime.now(timezone.utc) - event_age_gap
        for ev in events:
            last_ts = dateutil.parser.parse(ev["lastTimestamp"])
            ns = search_json(ev, "involvedObject.namespace")
            kind = search_json(ev, "involvedObject.kind")
            if last_ts > start_time and ns == namespace:
                name = search_json(ev, "involvedObject.name")
                message = ev["message"]
                filtered_events.append(ev)
                error_events_summary.append(f"{kind}.{name}.{message}\n")
                if kind == "Pod":
                    events_involved_pods.append(name)
        if error_events_summary:
            error_events_summary = "\t\t" + "\t\t".join(
                error_events_summary[0 : max(max_events_displayed, len(error_events_summary)) - 1]
            )
        else:
            error_events_summary = "\t\tNo events captured for summary"
        # get all pods in ns and if restarts > 0 add to involved pods name plus sum
        total_restart_count: int = 0
        pods_cmd: str = f"{binary_name} get Pods --context={context} --namespace={namespace} -o json"
        ns_pods: str = K8sConnection.shell(pods_cmd, target_service, kubeconfig)
        ns_pods: dict = from_json(ns_pods)
        if "items" in ns_pods:
            ns_pods = ns_pods["items"]
        for pod in ns_pods:
            try:
                search_time = K8sUtils.convert_age_to_search_time(age=event_age)
                search_filter = (
                    f"status.containerStatuses[?restartCount>`0` && lastState.terminated.finishedAt >= `{search_time}`]"
                )
                container_details = search_json(pod, search_filter)
                for container in container_details:
                    total_restart_count += container["restartCount"]
                    # append to log check name list so it gets checked there
                    events_involved_pods.append(container["name"])
            except Exception as e:
                logger.warning(f"Encountered {e} while checking pod restart counts, skipping this pod {pod}")
        # for each pod with events/restarts, get recent logs
        traced_pod_logs: dict = {}
        for podname in events_involved_pods:
            cmd: str = f'{binary_name} logs --context={context} --namespace={namespace} pod/{podname} --tail=20 | grep -E -i "{error_pattern}"'
            try:
                stdout = K8sConnection.shell(cmd, target_service, kubeconfig)
                if stdout:
                    traced_pod_logs[podname] = stdout
            except:
                logger.warning(f"Unable to fetch logs from pod {podname} with command: {cmd}")
        # process results
        pods_with_errors: int = len(traced_pod_logs.keys())
        traced_pod_logs = traced_pod_logs if traced_pod_logs else "None"
        error_events: int = len(filtered_events)
        error_events_status: str = (
            f"Passed {SYMBOL_GREEN_CHECKMARK}"
            if error_events == 0 and total_restart_count == 0
            else f"Failed {SYMBOL_RED_X}"
        )
        pod_errors_status: str = (
            f"Passed {SYMBOL_GREEN_CHECKMARK}" if pods_with_errors == 0 else f"Failed {SYMBOL_RED_X}"
        )
        error_pod_names: str = "None" if pods_with_errors == 0 else str(list(traced_pod_logs.keys()))
        if error_events > 0 or pods_with_errors > 0:
            all_passed = False
        status = f"Passed {SYMBOL_GREEN_CHECKMARK}" if all_passed else f"Failed {SYMBOL_RED_X}"
        report: str = f"""
Trace Namespace Summary: {status}
    Error Events: {error_events_status}
        Recent Event Count: {error_events}
        Error Event Messages: \n{error_events_summary}
    Pods with Error Logs: {pod_errors_status}
        Total Pod Restart Count: {total_restart_count}
        Erroring Pod Count: {pods_with_errors}
        Erroring Pod Names:
            {error_pod_names}
        Error Logs:
            {traced_pod_logs}
        """
        return report

    @staticmethod
    def object_condition_check(
        resource_kinds: str,
        namespace: str,
        context: str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        check_status_age: bool = False,
        failed_status_age: str = "12h",
        binary_name: str = "kubectl",
    ) -> str:
        ignore_reasons: list = ["PodCompleted"]
        namespace_objects: Union[dict, list, str] = K8sConnection.shell(
            cmd=f"{binary_name} get {resource_kinds} --context={context} --namespace={namespace} -o json",
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        if isinstance(namespace_objects, str):
            namespace_objects = from_json(namespace_objects)
        if "items" in namespace_objects:
            namespace_objects = namespace_objects["items"]
        all_passed: bool = True
        failed_statuses = []
        failed_status_gap: datetime.timedelta = parse_timedelta(failed_status_age)
        last_updated_time_allowed = datetime.now(timezone.utc) - failed_status_gap
        for ns_obj in namespace_objects:
            try:
                obj_name = ns_obj["metadata"]["name"]
                if "conditions" in ns_obj["status"]:
                    conditions = ns_obj["status"]["conditions"]
                    for condition in conditions:
                        condition_status = condition["status"]
                        ts_key: str = "lastUpdateTime" if "lastUpdateTime" in condition else "lastTransitionTime"
                        last_updated = dateutil.parser.parse(condition[ts_key])
                        if condition_status == "False" and (
                            not check_status_age or last_updated >= last_updated_time_allowed
                        ):
                            reason = condition["reason"]
                            condition_type = condition["type"]
                            message = condition["message"] if "message" in condition else "None"
                            if reason not in ignore_reasons:
                                failed_statuses.append(
                                    f"{obj_name}.{reason}.{condition_type} is False with message: {message}\n"
                                )
            except Exception as e:
                logger.warning(f"Encountered {e} while processing conditions in {ns_obj}")
        all_passed = False if len(failed_statuses) > 0 else True
        status = f"Passed {SYMBOL_GREEN_CHECKMARK}" if all_passed else f"Failed {SYMBOL_RED_X}"
        if len(failed_statuses) > 0:
            failed_statuses = "\t".join(failed_statuses)
        else:
            failed_statuses = "\tNo objects found with concerning condition statuses"
        report: str = f"""
Object Condition Status Summary: {status}
    {failed_statuses}
        """
        return report
