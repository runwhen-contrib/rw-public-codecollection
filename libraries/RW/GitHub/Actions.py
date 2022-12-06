import requests, logging, time
from dateutil import parser
from datetime import datetime, timezone
from RW.Utils.utils import parse_timedelta
from RW import platform


GITHUB_REST_API = "https://api.github.com"
GITHUB_NOAUTH_RATE_LIMIT = 60
GITHUB_AUTH_RATE_LIMIT = 5000

logger = logging.getLogger(__name__)

class Actions:
    def get_workflow_usage(self, owner: str, repo: str, workflow_filename: str, token: platform.Secret=None) -> dict:
        """Get the billing usage of a workflow. This does not contain time duration values for the workflow.
        Use a keyword such as get_workflow_times to fetch run times.


        Args:
            owner (str): _description_
            repo (str): _description_
            workflow_filename (str): _description_
            token (str, optional): _description_. Defaults to "".

        Raises:
            ValueError: _description_

        Returns:
            dict: _description_
        """
        headers : dict = {
            "Accept": "application/vnd.github+json",
        }
        if token:
            auth : dict = {"Authorization": f"Bearer {token.value}"}
            headers = headers | auth
        rsp : requests.Response = requests.get(
            url=f"{GITHUB_REST_API}/repos/{owner}/{repo}/actions/workflows/{workflow_filename}/timing",
            headers=headers,
            timeout=30,
        )
        if rsp.status_code != 200:
            raise ValueError(f"received response {rsp.json()} with status code {rsp.status_code}")
        return rsp.json()

    def get_workflow_runs(self, owner: str, repo: str, workflow_filename: str, token: platform.Secret=None) -> dict:
        """_summary_

        Args:
            owner (str): _description_
            repo (str): _description_
            workflow_filename (str): _description_
            token (str, optional): _description_. Defaults to "".

        Raises:
            ValueError: _description_

        Returns:
            dict: _description_
        """
        headers : dict = {
            "Accept": "application/vnd.github+json",
        }
        if token:
            auth : dict = {"Authorization": f"Bearer {token.value}"}
            headers = headers | auth
        rsp : requests.Response = requests.get(
            url=f"{GITHUB_REST_API}/repos/{owner}/{repo}/actions/workflows/{workflow_filename}/runs",
            headers=headers,
            timeout=30,
        )
        if rsp.status_code != 200:
            raise ValueError(f"received response {rsp.json()} with status code {rsp.status_code}")
        return rsp.json()

    def get_workflow_run_usage(self, owner: str, repo: str, run_id: str, token: platform.Secret=None) -> dict:
        """_summary_

        Args:
            owner (str): _description_
            repo (str): _description_
            run_id (str): _description_
            token (str, optional): _description_. Defaults to "".

        Raises:
            ValueError: _description_

        Returns:
            dict: _description_
        """
        headers : dict = {
            "Accept": "application/vnd.github+json",
        }
        if token:
            auth : dict = {"Authorization": f"Bearer {token.value}"}
            headers = headers | auth
        rsp : requests.Response = requests.get(
            url=f"{GITHUB_REST_API}/repos/{owner}/{repo}/actions/runs/{run_id}/timing",
            headers=headers,
            timeout=30,
        )
        if rsp.status_code != 200:
            raise ValueError(f"received response {rsp.json()} with status code {rsp.status_code}")
        return rsp.json()

    def get_workflow_times(
        self,
        owner: str,
        repo: str,
        workflow_filename: str,
        within_time:str="30d",
        token: platform.Secret=None,
    ) -> list[float]:
        """given a workflow and time range, fetch the run times of all the runs for said workflow,
        and provide those times in a list for further operations.

        Note: this keyword is prone to rate limits if using an authorized client.
        #TODO: Implement rate limiting construct (fixed or leaky bucket)

        Args:
            owner (str): owner or org name for the repo
            repo (str): github repo name
            workflow_filename (str): the filename of the github workflow file, such as `my-cicd.yaml`
            within_time (str, optional): a string time duration in the format '1d17h'. Defaults to "30d".
            token (str, optional): github auth token. Defaults to "".

        Returns:
            list[float]: a list of run times for a workflow, in seconds.
        """
        times : list[float] = []
        runs : dict = self.get_workflow_runs(owner, repo, workflow_filename, token)
        for run in runs["workflow_runs"]:
            if parser.parse(run["created_at"]) > (datetime.now(timezone.utc) - parse_timedelta(within_time)):
                usage = self.get_workflow_run_usage(owner, repo, run["id"], token)
                times.append(float(usage["run_duration_ms"]/1000))
        return times
