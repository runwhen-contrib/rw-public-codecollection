"""
rw.utils defines some common functions available to Library/Keyword
authors as python interfaces.  Some of these are also exposed as
Robot Keywords via RW.Utils.
"""
import os
import pprint
import functools
import time
import json
import yaml
import datetime
import re
import xml.dom.minidom
import urllib.parse
from enum import Enum
from typing import Union, Optional

from RW import platform

#TODO: refresh funcs using outdated dependencies
#TODO: port RWUtils over to here / merge / deduplicate
#TODO: add control structure keywords

class Status(Enum):
    NOT_OK = 0
    OK = 1


def is_bytes(val) -> bool:
    return isinstance(val, bytes)


def is_str(val) -> bool:
    return isinstance(val, str)


def is_str_or_bytes(val) -> bool:
    return isinstance(val, (str, bytes))


def is_int(val) -> bool:
    return isinstance(val, int)


def is_float(val) -> bool:
    return isinstance(val, float)


def is_bool(val) -> bool:
    return isinstance(val, bool)


def is_scalar(val) -> bool:
    return isinstance(val, (int, float, str, bytes, bool, type(None)))


def is_list(val) -> bool:
    return isinstance(val, list)


def is_dict(val) -> bool:
    return isinstance(val, dict)


def is_xml(val) -> bool:
    if not val or not is_str_or_bytes(val):
        return False
    try:
        xml.dom.minidom.parseString(val)
    except xml.parsers.expat.ExpatError:
        return False
    return True


def is_yaml(val) -> bool:
    if not val or not is_str_or_bytes(val):
        return False
    try:
        yaml.safe_load(val)
    except yaml.scanner.ScannerError:
        return False
    return True


def is_json(val, strict: bool = False) -> bool:
    if not val or not is_str_or_bytes(val):
        return False
    try:
        json.loads(val, strict=strict)
    except ValueError:
        return False
    return True


def from_json(json_str, strict: bool = False) -> object:
    if is_json(json_str, strict=strict):
        return json.loads(json_str, strict=strict)
    else:
        return json_str


def to_json(data: object) -> str:
    return json.dumps(data)


def from_yaml(yaml_str) -> object:
    if is_yaml(yaml_str):
        return yaml.load(yaml_str, Loader=yaml.SafeLoader)
    else:
        return yaml_str


def to_yaml(data: object) -> str:
    return yaml.dump(data)


def to_str(v) -> str:
    if is_bytes(v):
        return v.decode("unicode_escape")  # remove double forward slashes
    else:
        return str(v)


def to_bool(v) -> bool:
    """
    Convert the input parameter into a boolean value.
    """
    if is_bool(v):
        return v
    if is_str_or_bytes(v):
        if v.lower() == "true":
            return True
        elif v.lower() == "false":
            return False
    raise platform.TaskError(f"{v!r} is not a boolean value.")


def to_int(v) -> Union[int, list[int]]:
    """
    Convert the input parameter, which may be a scalar or a list, into
    integer value(s).
    """
    if is_scalar(v):
        return int(v)
    elif is_list(v):
        return [int(x) for x in v]
    else:
        raise ValueError(
            f"Expected a scalar or list value (actual value: {v})"
        )


def prettify(data) -> str:
    return pprint.pformat(data, indent=1, width=80)


def _calc_latency(func):
    """Calculate the runtime of the specified function."""

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        (default_ndigits, unit) = kwargs.pop("latency_params")
        ndigits = kwargs.get("ndigits", default_ndigits)
        if ndigits is not None:
            ndigits = int(ndigits)
        kwargs.pop("ndigits", None)

        start_time = time.perf_counter()
        val = func(*args, **kwargs)
        end_time = time.perf_counter()
        run_time = end_time - start_time
        platform.debug_log(
            f"Executed in {run_time:.5f} secs",
            console=False,
        )
        if unit not in ["s", "ms"]:
            raise platform.TaskError(
                f"Latency unit is {unit!r} (should be 's' or 'ms')."
            )
        if unit == "ms":
            run_time *= 1000.0
        return (round(run_time, ndigits), val)

    return wrapper


def latency(func, *args, **kwargs):
    @_calc_latency
    def doit(*args, **kwargs):
        return func(*args, **kwargs)

    return doit(*args, **kwargs)


def parse_url(url: str, verbose: bool = False) -> Union[str, int]:
    parsed_url = urllib.parse.urlparse(url)
    if verbose:
        platform.debug_log(f"URL components: {parsed_url}", console=False)
    return parsed_url


def encode_url(hostname: str, params: dict, verbose: bool = False) -> str:
    query_string = urllib.parse.urlencode(params, quote_via=urllib.parse.quote)
    encoded_url = hostname + query_string
    if verbose:
        platform.debug_log(f"Encoded URL: {encoded_url}", console=False)
    return encoded_url


def parse_timedelta(timestring: str) -> datetime.timedelta:

    timedelta_regex = r"((?P<days>\d+?)d)?((?P<hours>\d+?)h)?((?P<minutes>\d+?)m)?((?P<seconds>\d+?)s)?"
    pattern = re.compile(timedelta_regex)

    match = pattern.match(timestring)
    if match:
        parts = {k: int(v) for k, v in match.groupdict().items() if v}
        # TODO: Deal with negative timedelta values?
        return datetime.timedelta(**parts)
    else:
        raise platform.TaskError(
            f"{timestring!r} is not a valid time duration."
        )
