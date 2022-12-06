from benedict import benedict
import dateutil
SYMBOL_CHECKMARK = "\u2713"
SYMBOL_X = "\u2717"

class EventTasksMixin:
    def get_involved_object_name_list(self, events, distinct_values:bool=True) -> list:
        object_names : list = []
        if "items" in events:
            events = events["items"]
        for event in events:
            event : benedict = benedict(event, keypath_separator=None)
            kind : str = event["involvedObject", "kind"]
            name : str = event["involvedObject", "name"]
            object_name : str = f"{kind}/{name}"
            if distinct_values is True and object_name not in object_names:
                object_names.append(object_name)
            elif distinct_values is False:
                object_names.append(object_name)
        return object_names

    def check_events(
        self,
        events,
        search_name,
        number_of_warnings=5,
    ):
        results = benedict({}, keypath_separator=None)
        events = benedict(events, keypath_separator=None)
        results["check_passed"] = True
        results["events_count"] = 0
        results["found_any_events"] = False
        results["recent_warnings"] = []
        results["deployment_has_warnings"] = False
        results["effected_objects"] = []
        if events:
            results["found_any_events"] = True
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
                if object_path not in results["effected_objects"]:
                    results["effected_objects"].append(object_path)
            event_counts = [e["count"] for e in events]
            results["events_count"] = sum(event_counts)
            results["deployment_has_warnings"] = True
            results["recent_warnings"] = events[
                -min(number_of_warnings, len(events))
            ]["message"]
            results["check_passed"] = False
        return results

    def format_events_report(
        self,
        search_name,
        report_data=benedict({}, keypath_separator=None),
        events_doc_link="https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/",
        mute_suggestions:bool=False,
    ):
        report_lines = []
        report_data = benedict(report_data, keypath_separator=None)
        no_warnings = (
            SYMBOL_CHECKMARK
            if not report_data["deployment_has_warnings"]
            else SYMBOL_X
        )
        detected_event_stream = (
            SYMBOL_CHECKMARK
            if report_data["found_any_events"]
            else SYMBOL_X
        )
        report_lines.append("Event Stream Checks")
        report_lines.append(
            f"\tEvent Stream under name {search_name} found: {detected_event_stream}"
        )
        if not report_data["found_any_events"]:
            report_lines.append(
                "We couldn't find any events under the name {search_name}. Please check if the configured search name is correct."
            )
        else:
            report_lines.append(
                f"\tNo error events in stream for deployment: {no_warnings}"
            )
            report_lines.append(
                f'\tError Events count: {report_data["events_count"]}'
            )
            if len(report_data["recent_warnings"]) > 0:
                if isinstance(report_data["recent_warnings"], list):
                    recent_warnings = ", ".join(
                        report_data["recent_warnings"]
                    )
                else:
                    recent_warnings = report_data["recent_warnings"]
                report_lines.append(
                    f"\tMost recent error Event message(s): {recent_warnings}"
                )
            if len(report_data["effected_objects"]) > 0:
                affected_objects = ", ".join(
                    report_data["effected_objects"]
                )
                report_lines.append(
                    f"\tThe following objects are affected by these warnings: {affected_objects}"
                )
        return "\n".join(report_lines)
