"""
Patroni keyword library

Scope: Global
"""
import time, logging
from dataclasses import dataclass
from typing import Union, Optional

logger = logging.getLogger(__name__)


class Patroni:
    """
    Patroni keyword library
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def k8s_patroni_state_healthy(self, state: list, lag_tolerance: int = 1) -> bool:
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
        return healthy and found_leader

    def k8s_patroni_get_max_lag(
        self,
        state: list,
        min_lag: int = 1,
    ) -> int:
        max_lag: int = 0
        try:
            for member in state:
                if "Lag in MB" in member and int(member["Lag in MB"]) > max_lag and int(member["Lag in MB"]) > min_lag:
                    max_lag = int(member["Lag in MB"])
        except Exception as e:
            logger.warning(f"Unable to determine member data with state: {state} due to: {e}")
            return max_lag
        return max_lag

    def k8s_patroni_get_max_lag_member(
        self,
        state: list,
        min_lag: int = 1,
    ) -> Union[None, str]:
        lagged_member = None
        max_lag: int = 0
        try:
            # if the cluster is not highly available, do not provide a name to delete
            if len(state) <= 1:
                return None
            for member in state:
                if "Lag in MB" in member and int(member["Lag in MB"]) > max_lag and int(member["Lag in MB"]) > min_lag:
                    max_lag = int(member["Lag in MB"])
                    lagged_member = member["Member"]
        except e:
            logger.warning(f"Unable to determine member data with state: {state} due to: {e}")
            return lagged_member
        return lagged_member

    def k8s_patroni_get_laggy_members(self, state: list, lag_tolerance: int = 1) -> list:
        laggy_members: list = []
        try:
            # if the cluster is not highly available, do not provide a name to delete
            if len(state) <= 1:
                return laggy_members
            for member in state:
                if "Lag in MB" in member and int(member["Lag in MB"]) >= lag_tolerance:
                    laggy_members.append(member["Member"])
        except Exception as e:
            logger.warning(f"Unable to determine member data with state: {state} due to: {e}")
            return laggy_members
        return laggy_members

    def k8s_patroni_get_cluster_name(self, state: list) -> str:
        cluster_name = ""
        if "Cluster" in state[0]:
            cluster_name = state[0]["Cluster"]
        return cluster_name

    def k8s_patroni_template_deletemember(self, member_name, namespace, context, binary_name: str = "kubectl") -> str:
        cmd_str: str = ""
        if not member_name:
            return cmd_str
        cmd_str = f"{binary_name} delete pod/{member_name} -n {namespace} --context {context}"
        return cmd_str
