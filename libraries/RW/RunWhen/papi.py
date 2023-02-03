"""
RunWhen PAPI keyword library

Scope: Global
"""
import requests, datetime, re, time, json, os, urllib

from dataclasses import dataclass
from typing import Union, Optional

from RW import platform
from RW.Core import Core


class Papi:
    # TODO: refactor & improve docstrings
    """
    Papi is a keyword library that integrates with the RunWhen Public API.
    """
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self.token = None
        self.session = None
        self.base_path = "/api/v3/workspaces/"
        self._core: Core = Core()
        self.base_url = self._core.import_platform_variable("RW_API_BASE_URL")

    def _get_session(self):
        if self.session:
            return self.session
        self.session = platform.get_authenticated_session()
        return self.session

    def get_workspaces(self, names_only=False):
        """
        Fetches a list of workspaces from the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Workspaces  |

        Return Value:
        |   results   |
        """
        session = self._get_session()
        url = f"{self.base_url}{self.base_path}"
        rsp = session.get(url)
        if rsp.status_code == 404:
            rsp = []
        elif not rsp.status_code == 200:
            raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
        else:
            rsp = rsp.json()
        if names_only and "results" in rsp:
            rsp = [ws_name["name"] for ws_name in rsp["results"]]
        return rsp

    def get_slxs(self, workspace, names_only=False, short_name=True):
        """
        Fetches a list of SLXs within a workspace from the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Slxs  |   my-workspace    |
        | RW.RunWhen.Papi.Get Slxs  |   my-workspace    |   names_only=True     |

        Return Value:
        |   results   |
        """
        session = self._get_session()
        url = f"{self.base_url}{self.base_path}{workspace}/slxs"
        rsp = session.get(url)
        if rsp.status_code == 404:
            rsp = []
        elif not rsp.status_code == 200:
            raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
        else:
            rsp = rsp.json()
        if names_only and short_name and "results" not in rsp:  # malformed response
            rsp = []
        elif names_only and short_name:
            rsp = [slx["name"].split("--")[1] for slx in rsp["results"]]
        elif names_only:
            rsp = [slx["name"] for slx in rsp["results"]]

        return rsp

    def get_slis(self, workspace, names_only=False):
        """
        Fetches a list of SLIs present on SLXs within a workspace from the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Slis  |   my-workspace    |
        | RW.RunWhen.Papi.Get Slis  |   my-workspace    |   names_only=True     |

        Return Value:
        |   results   |
        """
        slis = []
        for slx in self.get_slxs(workspace, names_only=True):
            rsp = self.get_sli(workspace, slx, name_only=names_only)
            if rsp:
                slis.append(rsp)
        return slis

    def get_sli(self, workspace, slx, name_only=False, short_name=True):
        """
        Fetches a SLI under an SLX within a workspace from the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Sli  |   my-workspace    |   my-slx      |                       |
        | RW.RunWhen.Papi.Get Sli  |   my-workspace    |   my-slx      |   names_only=True     |

        Return Value:
        |   results   |
        """
        session = self._get_session()
        url = f"{self.base_url}{self.base_path}{workspace}/slxs/{slx}/sli"
        rsp = session.get(url)
        if rsp.status_code == 404:
            rsp = []
        elif not rsp.status_code == 200:
            raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
        else:
            rsp = rsp.json()
        if name_only and short_name and "name" in rsp:
            rsp = rsp["name"].split("--")[1]
        elif name_only and "name" in rsp:
            rsp = rsp["name"]
        # got a 404
        elif "name" not in rsp:
            rsp = []
        return rsp

    def get_sli_recent(self, workspace, slx, values_only=False, history: str = "5m", resolution: str = "30s"):
        """
        Returns an SLI's recent values from the Metricstore through the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Sli Recent  |   my-workspace    |   my-slx      |                        |                |                     |
        | RW.RunWhen.Papi.Get Sli Recent  |   my-workspace    |   my-slx      |   values_only=True     |    history=5m  |   resolution=30s    |

        Return Value:
        |   results   |
        """
        session = self._get_session()
        params = {
            "history": history,
            "resolution": resolution,
        }
        url = f"{self.base_url}{self.base_path}{workspace}/slxs/{slx}/sli/recent"
        rsp = session.get(url, params=params)
        if rsp.status_code == 404:
            rsp = []
        elif not rsp.status_code == 200:
            raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
        else:
            rsp = rsp.json()
        if values_only and "data" in rsp and "results" in rsp["data"]:
            rsp = rsp["data"]["result"][0]["values"]
        return rsp

    def get_all_recents_in_all_workspaces(self, history: str = "5m", resolution: str = "30s"):
        """
        Returns a list of all SLI recent values across all workspaces the service account can access through the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get All Recents In All Workspaces  |   names_only=True     |     history=5m  |   resolution=30s    |

        Return Value:
        |   results   |
        """
        all_ws_recents = {}
        for ws in self.get_workspaces(names_only=True):
            if ws not in all_ws_recents:
                all_ws_recents[ws] = {}
            all_ws_recents[ws] = self.get_all_recents_in_workspace(ws)
        return all_ws_recents

    def get_all_recents_in_workspace(self, workspace, history: str = "5m", resolution: str = "30s"):
        """
        Returns a list of all SLI recent values in a workspaces through the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get All Recents In Workspace  |   my-workspace    |     history=5m  |   resolution=30s    |

        Return Value:
        |   results   |
        """
        all_recents = {}
        for sli in self.get_slis(workspace, names_only=True):
            all_recents[sli] = self.get_sli_recent(
                workspace, sli, values_only=True, history=history, resolution=resolution
            )
        return all_recents

    def validate_recent_results(self, results):
        """
        EXPERIMENTAL
        TODO: finish for internal use
        """
        failures = {}
        for sli, values in results.items():
            if not values:
                failures[sli] = "no recent values"
        return failures

    def validate_all_workspace_recent_results(self, all_results):
        """
        EXPERIMENTAL
        TODO: finish for internal use
        """
        all_failures = {}
        for ws in self.get_workspaces(names_only=True):
            if ws not in all_failures:
                all_failures[ws] = {}
            if ws in all_results:
                all_failures[ws] = self.validate_recent_results(all_results[ws])
        failure_sum = 0
        all_failures["FAILURE_SUM"] = failure_sum
        return all_failures

    def get_runsessions(self, workspace=None, results_only=True):
        """
        Returns a list of runsessions in a workspaces through the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Runsessions  |   my-workspace    |

        Return Value:
        |   results   |
        """
        if not workspace:
            workspace = self._core.import_platform_variable("RW_WORKSPACE")
        session = self._get_session()
        url = f"{self.base_url}{self.base_path}{workspace}/runsessions"
        rsp = session.get(url)
        if rsp.status_code == 404:
            rsp = []
        elif not rsp.status_code == 200:
            raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
        else:
            rsp = rsp.json()
        if results_only and "results" in rsp:
            rsp = rsp["results"]
        return rsp

    def get_runsession(self, workspace, runsession_id=None, results_only=True):
        """
        Returns a specific runsession in a workspaces through the RunWhen Public API.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Runsession  |   my-workspace    |   00001   |

        Return Value:
        |   results   |
        """
        if not runsession_id:
            runsession_id = self._core.import_platform_variable("RW_SESSION_ID")
        runsession = None
        rsp = None
        if runsession_id:
            session = self._get_session()
            url = f"{self.base_url}{self.base_path}{workspace}/runsessions/{runsession_id}"
            rsp = session.get(url)
            if rsp.status_code == 404:
                rsp = []
            elif not rsp.status_code == 200:
                raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
            else:
                rsp = rsp.json()
        else:
            ValueError("One of the following where not provided to search with: runsession_id")
        return rsp

    def get_runrequest_report(
        self, workspace=None, slx=None, runrequest_id=None, results_only=True, template="basic_str_template"
    ):
        """
        Retrieves the report of a singular runrequest within a runsession.
        The total of all reports would typically be sent as part of a chat notification.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Runrequest Report  |   my-workspace    |     this-slx    |   00001   |
        | RW.RunWhen.Papi.Get Runrequest Report   |   my-workspace    |     this-slx    |   00001   |   template=console_template   |

        Return Value:
        |   report: str   |
        """
        if not workspace:
            workspace = self._core.import_platform_variable("RW_WORKSPACE")
        if not runrequest_id:
            runrequest_id = self._core.import_platform_variable("RW_RUNREQUEST_ID")
        session = self._get_session()
        url = f"{self.base_url}{self.base_path}{workspace}/slxs/{slx}/runbook/runs/{runrequest_id}/report?template={template}"
        rsp = session.get(url)
        if rsp.status_code == 404:
            rsp = []
        elif not rsp.status_code == 200:
            raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
        else:
            rsp = rsp.json()
        if results_only and "report" in rsp:
            rsp = rsp["report"]
        return rsp

    def get_runsession_report(self, workspace=None, runsession_id=None, template="basic_str_template"):
        """
        Retrieves the reports of all runrequests within a runsession and glues them together.
        The total of all reports would typically be sent as part of a chat notification.

        The results are scoped to the access of the service account.

        Examples:
        | RW.RunWhen.Papi.Get Runsession Report  |   my-workspace    |   00001   |

        Return Value:
        |   total_report: str   |
        """
        reports = []
        if not workspace:
            workspace = self._core.import_platform_variable("RW_WORKSPACE")
        if not runsession_id:
            runsession_id = self._core.import_platform_variable("RW_SESSION_ID")
        this_slx = self._core.import_platform_variable("RW_SLX")
        runsession = None
        rsp = None
        if runsession_id:
            session = self._get_session()
            url = f"{self.base_url}{self.base_path}{workspace}/runsessions/{runsession_id}"
            rsp = session.get(url)
            if rsp.status_code == 404:
                rsp = []
            elif not rsp.status_code == 200:
                raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
            else:
                rsp = rsp.json()
        else:
            ValueError("One of the following where not provided to search with: runsession_id")
        if "runRequests" in rsp:
            for rr in rsp["runRequests"]:
                slx = rr["slxShortName"]
                response_time = rr["responseTime"]
                runrequest_id = rr["id"]
                # A running slx cannot request its own report as it will always be empty
                if slx not in this_slx:
                    report = ""
                    if not response_time:
                        report = f"Task {slx} did not complete before the report was requested. If you would like it to wait for the report use the 'Depends On Past' setting."
                    else:
                        report = self.get_runrequest_report(
                            workspace, slx, runrequest_id=runrequest_id, template=template
                        )
                    reports.append(report)
        rsp = "\n".join(reports)
        return rsp

    def get_runsession_url(self, workspace=None, runsession_id=None, runrequest_id=None):
        if not workspace:
            workspace = self._core.import_platform_variable("RW_WORKSPACE")
        if not runsession_id:
            runsession_id = self._core.import_platform_variable("RW_SESSION_ID")
        frontend_url = self._core.import_platform_variable("RW_FRONTEND_URL")
        rsp = None
        if runsession_id and workspace:
            session = self._get_session()
            url = f"{self.base_url}{self.base_path}{workspace}/runsessions/{runsession_id}"
            rsp = session.get(url)
            if rsp.status_code == 404:
                rsp = []
            elif not rsp.status_code == 200:
                raise Exception(f"unexpected response from {url}: {rsp.status_code} and {rsp.text}")
            else:
                rsp = rsp.json()
        else:
            ValueError("One of the following where not provided to search with: workspace, runsession_id")
        runsession_link = "Runsession could not be found!"
        if "name" in rsp:
            params = {"cmd": f"get rs/{runsession_id}"}
            runsession_link = f"Platform Report For Runsession: {frontend_url}/map/{workspace}?{urllib.parse.urlencode(params, quote_via=urllib.parse.quote)}"
        return runsession_link

    def get_runsession_info(self, include_runsession_link: bool = True, include_runsession_stdout: bool = False) -> str:
        output: str = ""
        runsession_url: str = ""
        runsession_stdout: str = ""
        if not include_runsession_link and not include_runsession_stdout:
            return output
        if include_runsession_link:
            runsession_url = f"\n{self.get_runsession_url()}"
        if include_runsession_stdout:
            runsession_stdout = f"\n{self.get_runsession_report()}"
        output = f"{runsession_url}{runsession_stdout}"
        return output
