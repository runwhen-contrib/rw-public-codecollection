"""
Datadog keyword library

Scope: Global
"""
import time
import datadog
from dataclasses import dataclass
from typing import Union, Optional
from RW.Utils import utils
from RW.Utils.utils import Status


class Datadog:
    """
    Datadog is a keyword library for integrating with Datadog product.

    You need to provide a Datadog API Key and a Datadog App Key to use
    this library.

    The first step is to authenticate using `Connect To Datadog`.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        self.datadog_api_key = None
        self.datadog_app_key = None

    def connect_to_datadog(self, api_key: str, app_key: str) -> None:
        """
        Authentication for Datadog. This step is required before performing any
        Datadog operations.

        Examples:
        | Import User Variable | DATADOG_API_KEY    |                    |
        | Import User Variable | DATADOG_APP_KEY    |                    |
        | Connect To Datadog   | ${DATADOG_API_KEY} | ${DATADOG_APP_KEY} |
        """
        self.datadog_api_key = api_key
        self.datadog_app_key = app_key
        datadog.initialize(
            api_key=self.datadog_api_key, app_key=self.datadog_app_key
        )

    def get_metrics(
        self,
        query_str: str,
        time_window: int = 60,
        verbose: Union[str, bool] = False,
    ) -> object:
        """
        Get the metrics given a Datadog query.

        The ``time_window`` is the size of the data window. For example,
        600 seconds will return the metrics seen in the past 10 minutes.

        Examples:
        | ${res} = | RW.Datadog.Get Metrics | avg:system.load.1{host:my-minion1} | 60 |

        Return Values:
        | Metric data |

        Example:
        """
        verbose = utils.to_bool(verbose)
        end_time = int(time.time())
        start_time = end_time - int(time_window)
        if verbose is True:
            utils.debug_log(
                f"Query string: {query_str!r},"
                + f" time_window: {time_window},"
                + f" start_time: {start_time},"
                + f" end_time: {end_time}"
            )
        r = datadog.api.Metric.query(
            start=start_time, end=end_time, query=query_str
        )
        if verbose is True:
            utils.debug_log(r)

        status: Status = Status.NOT_OK
        if r["status"] == "ok":
            status = Status.OK

        @dataclass
        class Result:
            original_content: object
            content: dict
            last: Union[int, float]  # last metric in Datadog pointlist
            ok_status: Status = status.name
            ok: int = status.value

        pointlist = r["series"][0]["pointlist"]
        last_metric = pointlist[-1][1]
        return Result(r, pointlist, last_metric)

    def create_event(
        self,
        title: str,
        text: str,
        tags: Union[str, list[str]],
        verbose: Union[str, bool] = False,
    ) -> object:
        """
        Create a Datadog event.

        Examples:
        | ${res} = | RW.Datadog.Create Event | title=Test event | text=This is a test event | tags=['version:1', 'application:web'] |

        Return Values:
        | Datadog event data |
        """
        verbose = utils.to_bool(verbose)
        r = datadog.api.Event.create(title=title, text=text, tags=[tags])
        if verbose is True:
            utils.debug_log(r)

        status: Status = Status.NOT_OK
        if r["status"] == "ok":
            status = Status.OK

        @dataclass
        class Result:
            original_content: object
            content: dict
            id: int
            priority: Optional[str]
            related_event_id: str
            tags: str
            text: str
            title: str
            url: str
            ok_status: Status = status.name
            ok: int = status.value

        return Result(
            r,
            r,
            r["event"]["id"],
            r["event"]["priority"],
            r["event"]["related_event_id"],
            r["event"]["tags"],
            r["event"]["text"],
            r["event"]["title"],
            r["event"]["url"],
        )
