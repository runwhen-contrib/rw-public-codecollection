from benedict import benedict

SYMBOL_CHECKMARK = "\u2713"
SYMBOL_X = "\u2717"

class PvcTasksMixin:
    
    def check_pvc(
        self,
        pvcs,
        deployments=None,
    ):
        results = benedict({}, keypath_separator=None)
        results["check_passed"] = True
        results["deployment_pvcs"] = []
        results["pvcs"] = []
        results["unbound"] = []
        results["dangling"] = []
        # TODO: fetch pvc usage %
        if deployments:
            deployments = (
                deployments["items"]
                if "items" in deployments
                else [deployments]
            )
            for d in deployments:
                d = benedict(d, keypath_separator=None)
                if ["spec", "template", "spec", "volumes"] in d:
                    for v in d["spec", "template", "spec", "volumes"]:
                        v = benedict(v, keypath_separator=None)
                        if ["persistentVolumeClaim", "claimName"] in v:
                            results["deployment_pvcs"].append(
                                v["persistentVolumeClaim", "claimName"]
                            )
        if pvcs:
            if not isinstance(pvcs, list) and isinstance(pvcs, dict) and "items" not in pvcs:
                pvcs = [pvcs]
            pvcs = pvcs["items"] if "items" in pvcs else pvcs
            for pvc in pvcs:
                pvc = benedict(pvc, keypath_separator=None)
                results["pvcs"].append(pvc["metadata", "name"])
                if ["status", "phase"] in pvc and pvc[
                    "status", "phase"
                ] != "Bound":
                    results["unbound"].append(pvc["metadata", "name"])
                if (
                    ["status", "phase"] in pvc
                    and pvc["status", "phase"] != "Bound"
                    and pvc["metadata", "name"]
                    not in results["deployment_pvcs"]
                ):
                    results["dangling"].append(pvc["metadata", "name"])
        return results

    def format_pvc_report(
        self,
        report_data=benedict({}, keypath_separator=None),
        mute_suggestions:bool=False,
    ):
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        no_dangling = (
            SYMBOL_CHECKMARK
            if not len(report_data["dangling"]) > 0
            else SYMBOL_X
        )
        no_unbound = (
            SYMBOL_CHECKMARK
            if not len(report_data["unbound"]) > 0
            else SYMBOL_X
        )
        report_lines.append("Persistent Volume Claim Checks")
        report_lines.append(f"\tNo dangling volumes detected: {no_dangling}")
        report_lines.append(f"\tNo unbound volumes detected: {no_unbound}")
        return "\n".join(report_lines)
