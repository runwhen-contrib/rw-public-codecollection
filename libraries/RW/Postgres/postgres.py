"""
Postgres keyword library

Scope: Global
"""
import time
from dataclasses import dataclass
from typing import Union, Optional
from RW import platform


class Postgres:
    """
    Postgres keyword library
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def template_command(
        self,
        query: str,
        database: platform.Secret,
        username: platform.Secret,
        password: platform.Secret,
        hostname: str = None,
        default_flags: str = "-qAt",
        report: bool = False,
    ) -> str:
        if not database:
            raise ValueError(f"Error: Database not specified.")
        if len(password.value) == 0:
            raise ValueError(f"Error: Password is empty.")
        if report is True:
            query_options = "-c '\\t off' -c '\\a' -e"
        else:
            query_options = ""
        if not hostname:
            command = f"PGPASSWORD='${password.key}' psql {default_flags} -U ${username.key} -d ${database.key} {query_options} -c '\\timing on' -c '{query}'"
        else:
            command = f"PGPASSWORD='${password.key}' psql {default_flags} -U ${username.key} -d ${database.key} -h {hostname} {query_options} -c '\\timing on' -c '{query}'"
        return command

    def template_command_with_file(
        self,
        queryfilepath: str,
        database: platform.Secret,
        username: platform.Secret,
        password: platform.Secret,
        hostname: str = None,
        default_flags: str = "-qAt",
        report: bool = False,
    ) -> str:
        if not database:
            raise ValueError(f"Error: Database not specified.")
        if len(password.value) == 0:
            raise ValueError(f"Error: Password is empty.")
        if report is True:
            query_options = "-c '\\t off' -c '\\a' -e"
        else:
            query_options = ""
        if not hostname:
            command = f"PGPASSWORD='${password.key}' psql {default_flags} -U ${username.key} -d ${database.key} {query_options} -c '\\timing on' -f '{queryfilepath}'"
        else:
            command = f"PGPASSWORD='${password.key}' psql {default_flags} -U ${username.key} -d ${database.key} -h {hostname} {query_options} -c '\\timing on' -f '{queryfilepath}'"
        return command

    def parse_metric_and_time(self, psql_result: str) -> object:
        """Convert the output of the psql query and time into a dict with a metric and timing in ms.

        Args:
            psql_result (str): Expeects a multi-line string with the metric result and query timing. e.g. '52\nTime: 2.023 ms'

        Returns:
            query_details: a dict containing the metric and query time. e.g. {'metric': '52', 'time': '2.163 ms'}
        """
        psql_result = psql_result.split("Time: ")
        for item in range(len(psql_result)):
            psql_result[item] = psql_result[item].replace("\n", "")
        query_details = dict({"metric": psql_result[0], "time": psql_result[1]})
        return query_details

    @staticmethod
    def quote_query(query: str) -> str:
        """Simple helper method to escape specific characters that cause issues in the pod exec passthrough

        Args:
            query (str): _description_

        Returns:
            str: _description_
        """
        query = query.replace('"', '\\\\\\"')
        return query
