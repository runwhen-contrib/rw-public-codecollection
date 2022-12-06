from benedict import benedict

SYMBOL_CHECKMARK = "\u2713"
SYMBOL_X = "\u2717"

class NetworkTasksMixin:
    
    def check_networking(
        self,
        services,
        pods,
    ):

        services = benedict(services, keypath_separator=None)
        pods = benedict(pods, keypath_separator=None)
        results = benedict({}, keypath_separator=None)
        results["check_passed"] = True
        results["service_found"] = True
        results["service_selector_valid"] = True
        # TODO: add ingress mapping check
        # results["network","has_ingress"] = True
        # results["network","ingress_maps_service"] = True
        # ingresses = self.get(
        #     kind="Ingress",
        #     kubeconfig=kubeconfig,
        #     namespace=namespace,
        #     label_selector=labels,
        # )
        if services:
            services = services["items"] if "items" in services else [services]
            if services:
                for svc in services:
                    svc = benedict(svc, keypath_separator=None)
                    #selector = svc["spec", "selector"]
                    # TODO: rework to cross-ref selector
                    # for k, v in selector.items():
                    #     pods_selected = self.get(
                    #         kind="Pod",
                    #         kubeconfig=kubeconfig,
                    #         namespace=namespace,
                    #         label_selector=f"{k}={v}",
                    #         target_service=target_service,
                    #         distribution=distribution,
                    #     )
                    #     if not pods_selected:
                    #         results[
                    #             "service_selector_valid"
                    #         ] = False
            else:
                results["service_found"] = False
                results["service_selector_valid"] = False
        results["check_passed"] = (
            results["service_found"]
            and results["service_selector_valid"]
        )
        return results

    def format_networking_report(
        self,
        report_data=benedict({}, keypath_separator=None),
        mute_suggestions:bool=False,
    ):
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        svc_found = (
            SYMBOL_CHECKMARK
            if report_data["service_found"]
            else SYMBOL_X
        )
        svc_selector_valid = (
            SYMBOL_CHECKMARK
            if report_data["service_selector_valid"]
            else SYMBOL_X
        )
        report_lines.append("Networking Checks")
        report_lines.append(f"\tService found: {svc_found}")
        report_lines.append(
            f"\tService selector is valid: {svc_selector_valid}"
        )
        return "\n".join(report_lines)
