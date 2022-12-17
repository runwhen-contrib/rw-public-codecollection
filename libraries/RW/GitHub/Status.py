"""
GitHub Status service keyword library

Scope: Global
"""

from datetime import datetime, timezone
from enum import Enum
from typing import Set
from dateutil import parser
import requests

from RW.Utils.utils import parse_timedelta

GITHUB_SUMMARY_PAGE = "https://www.githubstatus.com/api/v2/summary.json"


class Status:
    """
    GitHub Status keyword library
    """

    class GitHubAvailability(Enum):
        NONE = "none"
        MINOR = "minor"
        MAJOR = "major"
        CRITICAL = "critical"

    GITHUB_AVAILABILITY_MAP = {
        GitHubAvailability.NONE: 1,
        GitHubAvailability.MINOR: 0.66,
        GitHubAvailability.MAJOR: 0.33,
        GitHubAvailability.CRITICAL: 0,
    }

    class GitHubComponentAvailability(Enum):
        OPERATIONAL = "operational"
        DEGRADED_PERFORMANCE = "degraded_performance"
        PARTIAL_OUTAGE = "partial_outage"
        MAJOR_OUTAGE = "major_outage"

    GITHUB_COMPONENT_AVAILABILITY_MAP = {
        GitHubComponentAvailability.OPERATIONAL: 1,
        GitHubComponentAvailability.DEGRADED_PERFORMANCE: 0.66,
        GitHubComponentAvailability.PARTIAL_OUTAGE: 0.33,
        GitHubComponentAvailability.MAJOR_OUTAGE: 0,
    }

    @staticmethod
    def _fetch_status_page():
        """
        Helper function which will handle basic HTTP operation of fetching GitHub
        status pages.

        Returns:
            Dictionary containing the values of the GitHub Status summary page
        """

        rsp = requests.get(GITHUB_SUMMARY_PAGE, timeout=10)
        if not rsp.status_code == 200:
            raise ValueError("The GitHub Status page could not be queried")
        status_page = rsp.json()
        return status_page

    def get_github_availability(self, components: Set[str] = None):
        """
        Calculates an availability metric for the GitHub platform, between 0 and 1.
        Optionally takes a subset of components from which to calculate this total.

        When no components are provided, the score is mapped from the indicator on the
        GitHub status page using the following values:
        - ``none`` : 1
        - ``minor`` : 0.66
        - ``major`` : 0.33
        - ``critical`` : 0

        If the components are provided, this function provides the average component
        availability score of the number of components provided in the set. These
        values are mapped from the component status attribute as follows:
        - ``operational`` : 1
        - ``degraded_performance`` : 0.66
        - ``partial_outage`` : 0.33
        - ``major_outage`` : 0

        Parameters:
            components (Set[str]): Set of components to optionally calculate
            availability score from. Current possible values at time of this release
            are:
                - "Git Operations"
                - "API Requests"
                - "Webhooks"
                - "Issues"
                - "Pull Requests"
                - "Actions"
                - "Packages"
                - "Pages"
                - "Codespaces"
                - "Copilot"

        Raises:
            ValueError: If the components provided do not match the list fetched from
            GitHub

        Returns:
            Value between 0 and 1 corresponding to the availability of the GitHub
            platform
        """

        status_page = self._fetch_status_page()

        if components is not None:
    
            # Generate a list of valid components
            valid_component_names = {component_name['name'] for component_name in status_page['components']}
            invalid_component_list = []

            # Test each input item against the list of valid components; create a list of invalid components if they exist
            for item in components:
                if item not in valid_component_names:
                    invalid_component_list.append(item)
            
            # Fail the step and identify which component isn't valid
            if len(invalid_component_list) != 0:
                raise ValueError(
                    f"{len(invalid_component_list)} component(s) is/are not found on the github status page. Invalid components are: {invalid_component_list} Valid components are: {valid_component_names} ;"
                )

            # Create a list of each component and it' current status
            component_status = [
                component
                for component in status_page["components"]    
                if component["name"] in components
            ]
            component_availability_score = 0.0

            # Compute the overall health score
            for component in component_status:
                component_availability_score += (
                    self.GITHUB_COMPONENT_AVAILABILITY_MAP[
                        self.GitHubComponentAvailability(component["status"])
                    ]
                )
            return component_availability_score / len(components)

        else:
            return self.GITHUB_AVAILABILITY_MAP[
                self.GitHubAvailability(status_page["status"]["indicator"])
            ]

    def get_unresolved_incidents(self, impact: str = None):
        """
        Get a list of any unresolved incidents on the GitHub platform. This function
        will only return incidents in the Investigating, Identified, or Monitoring state.

        Parameters:
            impact (str):  Impact level to filter unresolved incidents to. Possible
            values are "None", "Minor", "Major", and "Critical". Filtering to a lower
            level will include all incidents of a higher impact level. For instance,
            filtering to "Minor" will include all incidents of "Minor", "Major", and
            "Critical".

        Raises:
            ValueError: If the impact level does not match the supported values

        Returns:
            List of all unresolved incidents on the GitHub platform, optionally
            filtered by impact level
        """

        incidents = self._fetch_status_page()["incidents"]
        if impact is not None:
            incident_impact_levels = ["Critical", "Major", "Minor", "None"]
            filtered_impact_levels = []
            try:
                # Include all impact levels higher than the one specified
                filtered_impact_levels = incident_impact_levels[
                    0 : incident_impact_levels.index(impact)
                ]
            except Exception as exc:
                raise ValueError(
                    f"impact {impact} must be one of: None, Minor, Major, Critical",
                ) from exc
            incidents = [
                incident
                for incident in incidents
                if incident["impact"] in filtered_impact_levels
            ]

        return incidents

    def get_scheduled_maintenances(self, within_time: str = None):
        """
        Get a list of any active or upcoming scheduled maintenances on the GitHub
        platform. Optionally can constrain this list to maintenances occuring during
        a specified time period.

        Parameters:
            within_time (str): String which represents a duration of time, in the
            format "1d7h10m", with possible unit values being 'd' representing days,
            'h' representing hours, 'm' representing minutes, and 's' representing
            seconds.
        Raises:
            TaskError: If the within_time value does not represent a valid timedelta
        """
        upcoming_maintenances = self._fetch_status_page()[
            "scheduled_maintenances"
        ]
        if within_time is not None:
            upcoming_maintenances = [
                maintenance
                for maintenance in upcoming_maintenances
                if parser.parse(maintenance["scheduled_for"])
                < (datetime.now(timezone.utc) + parse_timedelta(within_time))
            ]
        return upcoming_maintenances
