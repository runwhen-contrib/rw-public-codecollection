"""
Google Cloud Service Health keyword library

Scope: Global
"""
import json
import requests
import logging
import dateutil.parser
from datetime import datetime, timedelta, timezone
from enum import Enum
from RW.Utils import parse_timedelta, csv_to_list

GCP_SERVICE_STATUS_URL: str = "https://status.cloud.google.com/incidents.json"

class ServiceHealth:
    #TODO: update docstrings
    """
    Google Cloud Service Health keyword library
    """
    class Severity(Enum):
        LOW: str = "low"
        MEDIUM: str = "medium"
        HIGH: str = "high"

    ROBOT_LIBRARY_SCOPE = "GLOBAL"


    def get_status_json(self):
        """
        Fetches the json incident history from https://status.cloud.google.com/incidents.json.

        Examples:
        | RW.GCP.ServiceHealth.Get Status Json  |

        Return Value:
        |   incident_history: json  |
        """
        rsp = requests.get(GCP_SERVICE_STATUS_URL, timeout=30)
        if not rsp.status_code == 200:
            raise  ValueError("The GCP Services Health page could not be queried")
        rsp = rsp.json()
        return rsp

    def filter_status_results(
        self,
        history,
        within_time: str = "10m",
        products: str = "",
        regions: str = "",
        severity_level: str = "",
        check_ongoing = True
    ):
        """
        Filters a json response containing GCP incident history entries.
        - ``history`` the json incident history.
        - ``within_time`` how much history will be kept during filtering.
        - ``products`` the list of products you would like to check for incidents.
        - ``regions`` which regions to consider for incidents.
        - ``severity_level`` the minimum severity level to consider, defaults to low (consider all).
        - ``check_ongoing`` Defaults to True - whether or not we only measure incidents that are ongoing.

        Examples:
        | RW.GCP.ServiceHealth.Filter Status Results   |   ${history}   |   ${within_time}  |
        | RW.GCP.ServiceHealth.Filter Status Results   |   ${history}   |   ${within_time}      |   products=${PRODUCT_CSV}  | regions=${REGIONS_CSV}   |

        Return Value:
        |   filtered_history: json  |
        """
        severities = self._get_severity_list(severity_level)
        products = csv_to_list(products)
        regions = csv_to_list(regions)
        matches = []
        history = self.filter_history_by_time(history, within_time)
        for entry in history:
            entry_products = [p["title"] for p in entry["affected_products"]]
            entry_regions = [r["id"] for r in entry["currently_affected_locations"]]

            entry_within_severity = True if entry["severity"] in severities else False
            entry_in_product_list = any(p in products for p in entry_products)
            entry_in_region_list = any(r in regions for r in entry_regions)
            if check_ongoing:
                ongoing = self._is_incident_ongoing(entry, within_time)
            else:
                ongoing = True
            if (
                (not products or entry_in_product_list)
                and (not regions or entry_in_region_list)
                and ongoing
                and entry_within_severity
            ):
                matches.append(entry)
        return matches
    
    def _is_incident_ongoing(self, entry, within_time) -> bool:
        ongoing = False
        now = datetime.now()
        datetime_in_past = datetime.now(timezone.utc) - parse_timedelta(within_time)
        entry_start = dateutil.parser.parse(entry["begin"])
        if "end" in entry and entry["end"]:
            entry_end = dateutil.parser.parse(entry["end"])
            if (
                (datetime_in_past >= entry_start and datetime_in_past <= entry_end)
                or (now >= entry_start and now <= entry_end)
            ):
                ongoing = True
        return ongoing
    
    def filter_history_by_time(self, history, within_time):
        """
        Helper method for removing history entries not within provided seconds range.
        """
        datetime_in_past = datetime.now(timezone.utc) - parse_timedelta(within_time)
        filtered_history = []
        for entry in history:
            entry_start_datetime = dateutil.parser.parse(entry["begin"])
            if entry_start_datetime >= datetime_in_past:
                filtered_history.append(entry)
        return filtered_history
    
    def _get_severity_list(self, level: str):
        if not level:
            level = ServiceHealth.Severity.LOW.value
        sev_list = []
        if level == ServiceHealth.Severity.LOW.value:
            sev_list.append(ServiceHealth.Severity.LOW.value)
            sev_list.append(ServiceHealth.Severity.MEDIUM.value)
            sev_list.append(ServiceHealth.Severity.HIGH.value)
        elif level == ServiceHealth.Severity.MEDIUM.value:
            sev_list.append(ServiceHealth.Severity.MEDIUM.value)
            sev_list.append(ServiceHealth.Severity.HIGH.value)
        elif level == ServiceHealth.Severity.HIGH.value:
            sev_list.append(ServiceHealth.Severity.HIGH.value)
        return sev_list