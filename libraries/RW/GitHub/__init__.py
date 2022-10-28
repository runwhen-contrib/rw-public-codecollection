"""
GitHub Core keyword library

Scope: Global
"""
import github
from github import Github
from typing import Optional, Union
from dataclasses import dataclass
from RW.Utils import utils


class GitHub:
    #TODO: refactor and update for platform use
    """
    GitHub keyword library defines keywords for interacting with GitHub
    services.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self.token = None

    def set_token(self, token: str) -> None:
        """
        Set the GitHub token. If the token is set then subsequent calls to
        GitHub keywords such as `Create Issue` don't need to specify the token.
        Examples:
        | RW.GitHub.Set Token | ${GITHUB_TOKEN} |
        """
        self.token = token

    def get_token(self) -> str:
        """
        Return the GitHub token which was previously set using `Set Token`.
        Examples:
        | ${gh_token} = | RW.GitHub.Get Token |
        Return Value:
        | GitHub token |
        """
        if self.token is None:
            utils.task_error("GitHub token is not defined.")
        return self.token

    def create_issue(
        self,
        repo_name: str,
        title: str,
        assignee: Union[str, object] = github.GithubObject.NotSet,
        labels: Union[str, list[str], object] = github.GithubObject.NotSet,
        body: Union[str, object] = github.GithubObject.NotSet,
        token: Optional[str] = None,
    ) -> object:
        """
        Create a new GitHub issue.
        Examples:
        | ${res} = | Create Issue | my-project | Bug ABC in my-project | vui | bug | Long description... | ${gh_token} |
        Return Value:
        | GitHub issue |
        """
        if token is None:
            token = self.get_token()
        if labels is not None:
            if utils.is_str(labels):
                labels = labels.split()
        g = Github(token)
        utils.info_log(f"create_issue repo name: {repo_name}")
        repo = g.get_repo(repo_name)

        latency, res = utils.latency(
            repo.create_issue,
            title=title,
            body=body,
            assignee=assignee,
            labels=labels,
            latency_params=[6, "s"],
        )

        @dataclass
        class Result:
            original_content: object
            login: str
            latency: float

        return Result(res, res.login, latency)

    def get_user(
        self, user: Optional[str] = None, token: Optional[str] = None
    ) -> object:
        """
        Get GitHub user info.
        Examples:
        | ${user} | Get User | vui | ${gh_token} |
        Return Value:
        | User info |
        User Info:
        | result.login | "lumphammer9" |
        | result.id    | 88601986 |
        | result.url   | "https://api.github.com/users/lumphammer9" |
        | result.name: | ... |
        """
        if token is None:
            token = self.get_token()
        g = Github(token)

        if user is None:
            latency, res = utils.latency(
                g.get_user,
                latency_params=[6, "s"],
            )
        else:
            latency, res = utils.latency(
                g.get_user,
                user,
                latency_params=[6, "s"],
            )

        @dataclass
        class Result:
            original_content: object
            login: str
            latency: float

        return Result(res, res.login, latency)

    def get_repo(
        self,
        name: str,
        user: Optional[str] = None,
        token: Optional[str] = None,
    ) -> object:
        """
        Get the GitHub repository with the given name.
        Examples:
        | ${repo} = | Get Repo | my-app | token=${gh_token} |
        Return Value:
        | Repo data |
        """
        if token is None:
            token = self.get_token()
        g = Github(token)
        if user is None:
            latency, res = utils.latency(
                g.get_user().get_repo,
                name,
                latency_params=[6, "s"],
            )
        else:
            latency, res = utils.latency(
                g.get_user(user).get_repo,
                name,
                latency_params=[6, "s"],
            )

        @dataclass
        class Result:
            original_content: object
            full_name: str
            url: str
            latency: float

        return Result(res, res.full_name, res.url, latency)

    def get_repos(self, token: Optional[str] = None) -> object:
        """
        Get all the repositories found in GitHub.
        Examples:
        | ${repo} = | Get Repos | token=${gh_token} |
        Return Value:
        | List of repo data |
        TBD
        :return: List of repo names
        """
        if token is None:
            token = self.get_token()
        g = Github(token)
        latency, res = utils.latency(
            g.get_user().get_repos,
            latency_params=[6, "s"],
        )

        @dataclass
        class Result:
            original_content: object
            repos: list[str]
            latency: float

        return Result(res, [repo.name for repo in res], latency)
