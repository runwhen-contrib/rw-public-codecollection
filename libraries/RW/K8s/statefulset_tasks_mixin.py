from benedict import benedict
class StatefuletTasksMixin:
    def stateful_sets_ready(
        self, statefulsets
    ):
        if "items" in statefulsets:
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
