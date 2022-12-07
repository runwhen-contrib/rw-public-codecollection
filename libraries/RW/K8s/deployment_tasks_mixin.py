from benedict import benedict
from RW.Utils.utils import parse_numerical

SYMBOL_CHECKMARK = "\u2713"
SYMBOL_X = "\u2717"

class DeploymentTasksMixin:

    def get_available_replicas(self, deployment: dict) -> int:
        deployment = benedict(deployment, keypath_separator=None)
        return int(deployment["status", "availableReplicas"])

    def get_desired_replicas(self, deployment: dict) -> int:
        deployment = benedict(deployment, keypath_separator=None)
        return int(deployment["status", "replicas"])

    def has_hpa(self, hpas: dict, deployment: dict) -> bool:
        if not hpas:
            return False
        if "items" in hpas:
            hpas = hpas["items"]
        deployment : benedict = benedict(deployment, keypath_separator=None)
        deployment_name : str = deployment["metadata","name"]
        for hpa in hpas:
            hpa : benedict = benedict(hpa, keypath_separator=None)
            scale_ref_name = hpa["spec","scaleTargetRef","name"]
            if scale_ref_name == deployment_name:
                return True
        return False

    def troubleshoot_deployment(self, deployment, search_name):
        return self.check_resources(deployment, search_name)

    def check_resources(
        self,
        deployment,
        search_name,
    ) -> dict:
        #TODO: update to new check format
        results = benedict({}, keypath_separator=None)
        deployment = benedict(deployment, keypath_separator=None)
        results = benedict({}, keypath_separator=None)
        results["check_passed"] = True
        results["name"] = search_name
        results["mem_requests_per_replica"] = 0
        results["cpu_requests_per_replica"] = 0
        results["mem_limits_per_replica"] = 0
        results["cpu_limits_per_replica"] = 0
        results["resources_missing"] = False
        results["requests_missing"] = False
        results["limits_missing"] = False
        results["replicas"] = 0
        results["mem_requests_sum"] = 0
        results["cpu_requests_sum"] = 0
        results["mem_limits_sum"] = 0
        results["cpu_limits_sum"] = 0
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
        results["deployment_found"] = bool(deployment)
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
                        "container_resources", container["name"]
                    ] = None  # none means no resource details found
                    results["resources_missing"] = True
                    results["requests_missing"] = True
                    results["limits_missing"] = True
                else:
                    results[
                        "container_resources", container["name"]
                    ] = resources
                    if "limits" in resources:
                        results[
                            "mem_limits_per_replica"
                        ] += parse_numerical(
                            resources["limits", "memory"]
                        )
                        results[
                            "cpu_limits_per_replica"
                        ] += parse_numerical(resources["limits", "cpu"])
                    else:
                        results["limits_missing"] = True
                    if "requests" in resources:
                        results[
                            "mem_requests_per_replica"
                        ] += parse_numerical(
                            resources["requests", "memory"]
                        )
                        results[
                            "cpu_requests_per_replica"
                        ] += parse_numerical(resources["requests", "cpu"])
                    else:
                        results["requests_missing"] = True
            results["replicas"] = deployment["spec", "replicas"]
            results["mem_requests_sum"] = (
                results["mem_requests_per_replica"]
                * results["replicas"]
            )
            results["cpu_requests_sum"] = (
                results["cpu_requests_per_replica"]
                * results["replicas"]
            )
            results["mem_limits_sum"] = (
                results["mem_limits_per_replica"]
                * results["replicas"]
            )
            results["cpu_limits_sum"] = (
                results["cpu_limits_per_replica"]
                * results["replicas"]
            )
            if (
                results["requests_missing"]
                or results["limits_missing"]
                or results["resources_missing"]
            ):
                results["check_passed"] = False
        return results


    def format_resources_report(
        self,
        search_name,
        report_data=benedict({}, keypath_separator=None),
        resource_doc_link="https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/",
        mute_suggestions:bool=False,
    ):
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        resources_set_symbol = (
            SYMBOL_CHECKMARK
            if not report_data["resources_missing"]
            else SYMBOL_X
        )
        limits_set_symbol = (
            SYMBOL_CHECKMARK
            if not report_data["limits_missing"]
            else SYMBOL_X
        )
        requests_set_symbol = (
            SYMBOL_CHECKMARK
            if not report_data["requests_missing"]
            else SYMBOL_X
        )
        found_symbol = (
            SYMBOL_CHECKMARK
            if report_data["deployment_found"]
            else SYMBOL_X
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
        if not mute_suggestions and (
            report_data["resources_missing"]
            or report_data["limits_missing"]
            or report_data["requests_missing"]
        ):
            report_lines.append(
                f"\tNot all containers have resources fully set, consider reviewing: {resource_doc_link}"
            )
        else:
            report_lines.append(
                f'\tDeployment {report_data["name"]} requests {report_data["mem_requests_sum"]} memory limited to {report_data["mem_limits_sum"]}'
                f', and requests cpu {report_data["cpu_requests_sum"]} limited to {report_data["cpu_limits_sum"]}'
            )
        return "\n".join(report_lines)
