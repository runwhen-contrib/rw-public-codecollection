"""
Jira keyword library

Scope: Global
"""
import jira
from typing import Optional
from RW.Utils import utils


class Jira:
    #TODO: refactor for new platform use
    """
    Jira is a keyword library for integrating with the Jira system.
    You need to provide a Jira server URL, a Jira User, and a Jira User Token
    to use this library.
    The first step is to authenticate using `Connect To Jira`.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        self.auth_jira = None

    def connect_to_jira(self, server: str, user: str, token: str) -> None:
        """
        Authentication for Jira. This step is required before performing any
        Jira operations.
        Examples:
        | Import User Variable | JIRA_URL           | | |
        | Import User Variable | JIRA_USER          | | |
        | Import User Variable | JIRA_USER_TOKEN    | | |
        | Connect To Jira      | server=${JIRA_URL} | user=${JIRA_USER} | token=${JIRA_USER_TOKEN} |
        """
        self.auth_jira = jira.JIRA(server, basic_auth=(user, token))

    def create_issue(
        self,
        project: str,
        summary: str,
        description: str,
        verbose: bool = False,
    ) -> object:
        """
        Create a new Jira issue.
        Examples:
        | ${issue} = | Create Issue | APP | App core dumps | Long description... |
        Return Value:
        | Issue data |
        """
        issue = self.auth_jira.create_issue(
            project=project,
            summary=summary,
            description=description,
            issuetype={
                "name": "Bug"
            },  # "Epic", "New Feature", "Task", "Improvement"
        )
        if verbose:
            utils.debug_log(
                f"Jira create issue result:\n{utils.prettify(issue.__dict__)}",
                console=False,
            )
        return issue  # inspect issue.__dict__ for more details

    def get_issue(
        self,
        issue_id: str,
        fields: Optional[str] = None,
        verbose: bool = False,
    ) -> object:
        """
        Get a Jira issue.
        ``fields`` is a comma-separated string of issue fields.
        Tip: You can first get the issue which will include all the issue fields, then browse through
        the fields and decide on a smaller set of fields to return in the result.
        Examples:
        | ${issue} = | Get Issue | 1234 |
        Return Value:
        | Issue data |
        """
        issue = self.auth_jira.issue(issue_id, fields=fields)
        if verbose:
            utils.debug_log(
                f"Jira get issue result:\n{utils.prettify(issue.__dict__)}",
                console=False,
            )
        return issue

    def assign_issue(self, issue_id: str, assignee: str) -> bool:
        """
        Assign a user to the issue.
        Examples:
        | Assign Issue | 1234 | vui |
        Return Value:
        | Always returns True |
        """
        return self.auth_jira.assign_issue(issue_id, assignee)

    def search_issues(self, project: str, verbose: bool = False) -> object:
        """
        Search Jira
        This keyword currently returns all the issues in a project.
        Examples:
        | ${issues} = | Search Issues | APP |
        Return Value:
        | List of issues |
        """
        issues = self.auth_jira.search_issues(f"project={project}")
        if verbose:
            utils.debug_log(
                f"Jira issues:\n{utils.prettify(issues.__dict__)}",
                console=False,
            )
        return issues
