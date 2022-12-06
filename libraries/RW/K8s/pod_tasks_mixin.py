from benedict import benedict

SYMBOL_CHECKMARK = "\u2713"
SYMBOL_X = "\u2717"

class PodTasksMixin:

    def get_pod_names_with_logs(self, named_pod_logs : dict) -> list:
        pod_names : list = []
        for key,value in named_pod_logs.items():
            if value and key not in pod_names:
                pod_names.append(key)   
        return pod_names

    def check_pods(
        self,
        pods,
        search_name=None,
    ):
        if not isinstance(pods, list) and isinstance(pods, dict) and "items" not in pods:
            pods = [pods]
        pods = pods["items"] if "items" in pods else pods
        results = benedict({}, keypath_separator=None)
        results["check_passed"] = True
        results["liveness_checks"] = True
        results["readiness_checks"] = True
        results["restart_count"] = 0
        results["pods_healthy"] = True
        results["pod_list"] = []
        results["container_statuses"] = []
        results["containers_healthy"] = True
        temp_pod_names = []
        if pods:
            if search_name:
                pods = [
                    p for p in pods if search_name in benedict(p, keypath_separator=None)["metadata"]["name"]
                ]
            for pod in pods:
                pod = benedict(pod, keypath_separator=None)
                if (
                    pod["status", "phase"] == "Failed"
                    or pod["status", "phase"] == "Unknown"
                ):
                    results["pods_healthy"] = False
                    temp_pod_names.append(pod["metadata", "name"])
                if ["spec", "containers"] in pod:
                    for container in pod["spec", "containers"]:
                        if "readinessProbe" not in container:
                            results["readiness_checks"] = False
                            temp_pod_names.append(pod["metadata", "name"])
                        if "livenessProbe" not in container:
                            results["liveness_checks"] = False
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
                                results["containers_healthy"] = False
                                temp_pod_names.append(pod["metadata", "name"])
                            if ["state", "waiting"] in c_status or [
                                "state",
                                "terminated",
                            ] in c_status:
                                results["containers_healthy"] = False
                                results["container_statuses"].append(
                                    str(c_status["state"])
                                )
                                temp_pod_names.append(pod["metadata", "name"])
                            results["restart_count"] += c_status[
                                "restartCount"
                            ]
        for pod_name in temp_pod_names:
            pod_name = f"Pod/{pod_name}"
            if pod_name not in results["pod_list"]:
                results["pod_list"].append(pod_name)
        results["check_passed"] = (
            results["pods_healthy"]
            and results["containers_healthy"]
            and results["liveness_checks"]
            and results["readiness_checks"]
        )
        return results

    def format_pods_report(
        self,
        report_data=benedict({}, keypath_separator=None),
    ):
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        pods_healthy = (
            SYMBOL_CHECKMARK
            if report_data["pods_healthy"]
            else SYMBOL_X
        )
        live_present = (
            SYMBOL_CHECKMARK
            if report_data["liveness_checks"]
            else SYMBOL_X
        )
        ready_present = (
            SYMBOL_CHECKMARK
            if report_data["readiness_checks"]
            else SYMBOL_X
        )
        containers_healthy = (
            SYMBOL_CHECKMARK
            if report_data["containers_healthy"]
            else SYMBOL_X
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
            f'\tTotal Restart Count: {report_data["restart_count"]}'
        )
        if report_data["container_statuses"]:
            container_statuses = ", ".join(
                report_data["container_statuses"]
            )
            report_lines.append(
                f"\tContainer Status List: {container_statuses}"
            )
        if (
            not report_data["pods_healthy"]
            and report_data["pod_list"]
        ):
            pod_list = ", ".join(report_data["pod_list"])
            report_lines.append(f"\tUnhealthy Pod List: {pod_list}")
        return "\n".join(report_lines)
