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
        hostname: str="hostname",
        default_flags: str="-qAt"
    ) -> str:
        command = f"PGPASSWORD='${password.key}' psql {default_flags} -U ${username.key} -d ${database.key} -h {hostname} -c '{query}'"
        return command