"""
GitLab keyword library

Scope: Global
"""
import gitlab
from dataclasses import dataclass
from RW.Utils import utils


class GitLab:
    #TODO: refactor for new platform use
    """
    GitLab is a keyword library for integrating with the GitLab system.
    You need to provide a GitLab URL and a GitLab API Token to use
    this library.
    The first step is to authenticate using `Create Session`.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        self.url = None
        self.token = None
        self.gl = None

    def create_session(self, url: str, token: str) -> object:
        """
        Create a GitLab session.
        Examples:
        | Import User Variable     | GITLAB_URL    | |
        | Import User Variable     | GITLAB_TOKEN  | |
        | RW.GitLab.Create Session | ${GITLAB_URL} | ${GITLAB_TOKEN} |
        Return Value:
        | GitLab handle |
        """
        self.gl = gitlab.Gitlab(url=url, private_token=token)
        return self.gl

    def get_projects(self):
        """
        Get all projects found in GitLab.
        Examples:
        | ${projects} = | RW.GitLab.Get Projects |
        """
        latency, res = utils.latency(
            self.gl.projects.list,
            latency_params=[3, "s"],
        )

        @dataclass
        class Result:
            original_content: object
            names: list[str]
            latency: float

        return Result(
            res,
            [x.name for x in res],
            latency,
        )
