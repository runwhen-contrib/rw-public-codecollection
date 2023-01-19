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
        hostname: str=None,
        default_flags: str="-qAt"
    ) -> str:
        if not database:
                raise ValueError(f"Error: Database not specified.")
        if len(password.value) == 0:
                raise ValueError(f"Error: Password is empty.")
        if not hostname: 
            command = f"PGPASSWORD='${password.key}' psql {default_flags} -U ${username.key} -d ${database.key} -c '{query}'"
        else:
            command = f"PGPASSWORD='${password.key}' psql {default_flags} -U ${username.key} -d ${database.key} -h {hostname} -c '{query}'"
        return command