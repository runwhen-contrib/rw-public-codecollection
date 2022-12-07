from benedict import benedict

class PdbTasksMixin:
    def check_pdb(
        self,
        pdbs,
    ):
        # TODO: finish pdbs
        pdbs = benedict(pdbs, keypath_separator=None)
        results = benedict({}, keypath_separator=None)
        results["check_passed"] = True
        results["exists"] = False
        results["maps"] = False
        results["pdbs"] = []
        return results

    def format_pdb_report(
        self,
        report_data=benedict({}, keypath_separator=None),
        pdb_doc_link="https://kubernetes.io/docs/tasks/run-application/configure-pdb/",
        mute_suggestions:bool=False,
    ):
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        # TODO: finish pdb
        # exists
        # maps to deployment
        # not 0
        # not 100%
        if not mute_suggestions and not report_data["check_passed"]:
            report_lines.append(
                f"\tNot all containers have resources fully set, consider reviewing: {pdb_doc_link}"
            )
        report_lines.append("Pod Disruption Budget Checks")
        return "\n".join(report_lines)
