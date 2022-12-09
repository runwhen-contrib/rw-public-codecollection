"""
Patroni keyword library

Scope: Global
"""
import time
from dataclasses import dataclass
from typing import Union, Optional


class Patroni:
    """
    Patroni keyword library
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def patroni_state_healthy(self, state: list, lag_tolerance: int=1) -> bool:
        healthy: bool = True
        last_timeline = None
        found_leader: bool = False
        for member in state:
            # first determine if all replicas are on the same timeline
            if last_timeline is not None and last_timeline != member["TL"]:
                healthy = False
            last_timeline = member["TL"]
            # check running
            # TODO: revisit state tolerance and determine acceptable rollover states
            if member["State"] != "running":
                healthy = False
            # we should have a leader
            if member["Role"] == "Leader":
                found_leader = True
            if "Lag in MB" in member and int(member["Lag in MB"]) > lag_tolerance:
                healthy = False
        return (healthy and found_leader)