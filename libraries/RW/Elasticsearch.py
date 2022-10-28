"""
Elasticsearch keyword library

Scope: Global
"""
from dataclasses import dataclass
from robot.libraries.BuiltIn import BuiltIn
from typing import Union
from RW.Utils import utils
from RW.Utils.utils import Status
from RW import platform


class Elasticsearch:
    #TODO: refactor for new platform use
    """
    Elasticsearch is a keyword library for integrating with the Elasticsearch
    search engine.
    At this time, basic authentication is done by passing the username/password
    in the URL.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        BuiltIn().import_library("RW.HTTP")
        self.rw_http = BuiltIn().get_library_instance("RW.HTTP")

    def get_health_status(
        self,
        url: str,
        verbose: Union[str, bool] = False,
    ) -> None:
        """
        Check the Elasticsearch cluster health status. The status can be
        "green", "yellow", or "red".

        Examples:
        | ${res} = | Get Health Status | ${ELASTICSEARCH_URL} |

        Return Value:
        | Health data |
        """
        verbose = utils.to_bool(verbose)
        r = self.rw_http.get(f"{url}/_cluster/health")
        if verbose is True:
            platform.debug_log(r)

        status: Status = Status.NOT_OK
        if r.status_code in [200] and r.json()["status"] == "green":
            status = Status.OK

        @dataclass
        class Result:
            original_content: object
            content: dict
            status_code: int = r.status_code
            reason: str = r.reason
            cluster_name: str = r.json()["cluster_name"]
            cluster_status: str = r.json()["status"]
            ok_status: Status = status
            ok: int = status.value

        return Result(r, r.json())

    def get_shard_health_status(
        self,
        url: str,
        index: str,
        verbose: Union[str, bool] = False,
    ) -> None:
        """
        Check the Elasticsearch cluster shard health status. The status can be
        "green", "yellow", or "red".

        Examples:
        | ${res} = | Get Shard Health Status | ${ELASTICSEARCH_URL} | index=.geoip_databases |

        Return Value:
        | Health data |

        """
        verbose = utils.to_bool(verbose)
        r = self.rw_http.get(f"{url}/_cluster/health/{index}?level=shards")
        if verbose is True:
            platform.debug_log(r)

        status: Status = Status.NOT_OK
        if r.status_code in [200] and r.json()["status"] == "green":
            status = Status.OK

        @dataclass
        class Result:
            original_content: object
            content: dict
            status_code: int = r.status_code
            reason: str = r.reason
            cluster_name: str = r.json()["cluster_name"]
            cluster_status: str = r.json()["status"]
            ok_status: Status = status
            ok: int = status.value

        return Result(r, r.json())
