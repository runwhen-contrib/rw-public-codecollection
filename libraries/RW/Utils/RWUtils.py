"""
RWUtils keyword library.

This exposes some of the rw.utils functions (python interfaces) to
robot authors as robot interfaces.

Scope: Global
"""

import re, os, random, traceback
import requests
from typing import Optional, Union, List
from robot.libraries.BuiltIn import BuiltIn
from RW import platform
from RW.Utils import utils



class RWUtils:
    #TODO: merge with utils
    """Utility keyword library for useful bits and bobs."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def prettify(self, *args, **kwargs) -> str:
        return utils.prettify(*args, **kwargs)

    def is_string(self, val) -> bool:
        """
        Check if argument is a string.

        :param val: Value to check
        """
        return utils.is_str(val)

    def is_integer(self, val) -> bool:
        """
        Check if argument is an integer.

        :param val: Value to check
        """
        return utils.is_int(val)

    def is_boolean(self, val) -> bool:
        """
        Check if argument is a boolean.

        :param val: Value to check
        """
        return utils.is_bool(val)

    def to_json(self, *args, **kwargs) -> str:
        """
        Convert from Python dictionary to JSON string.
        """
        return utils.to_json(*args, **kwargs)

    def string_to_json(self, *args, **kwargs) -> str:
        """Convert a string to a JSON serializable object and return it.

        :param str: JSON string
        :return: JSON serializable object of the string

        """
        return utils.string_to_json(*args, **kwargs) 

    def search_json(self, *args, **kwargs) -> dict:
        """Search JSON dictionary using jmespath.

        :data dict: JSON dictionary to search through. 
        :pattern str: Pattern to search. See https://jmespath.org/? to test search strings.
        :return: JSON Dict of search results. 

        """
        return utils.search_json(*args, **kwargs) 

    def from_json(self, *args, **kwargs) -> object:
        """
        Convert from JSON string to Python dictionary.
        """
        return utils.from_json(*args, **kwargs)

    def to_boolean(self, v) -> int:
        """
        Convert a value into a Boolean.
        """
        return utils.to_bool(v)

    def to_integer(self, v) -> Union[int, List[int]]:
        """
        Convert a value into an integer or list of integers.
        """
        return utils.to_int(v)

    def parse_url(self, url: str, verbose: bool = False) -> object:
        """
        Parse the URL into its components. Set the `verbose` parameter to
        ${true} to show the available components.
        """
        return utils.parse_url(url, verbose)

    def get_hostname_from_url(self, url: str, verbose: bool = False) -> str:
        """
        Get the hostname from the specified URL.
        """
        return utils.parse_url(url, verbose).netloc.split(":")[0]

    def get_port_from_url(self, url: str, verbose: bool = False) -> str:
        """
        Get the port from the specified URL.
        """
        return utils.parse_url(url, verbose).netloc.split(":")[1]

    def get_protocol_from_url(self, url: str, verbose: bool = False) -> str:
        """
        Get the protocol from the specified URL.
        :return: HTTP protocol (should be 'http' or 'https')
        """
        return utils.parse_url(url, verbose).scheme

    def get_path_from_url(self, url: str, verbose: bool = False) -> str:
        """
        Get the path from the specified URL.
        """
        return utils.parse_url(url, verbose).path

    def get_params_from_url(self, url: str, verbose: bool = False) -> str:
        """
        Get the parameters from the specified URL.
        """
        return utils.parse_url(url, verbose).params

    def get_query_string_from_url(
        self, url: str, verbose: bool = False
    ) -> str:
        """
        Get the query string from the specified URL.
        """
        return utils.parse_url(url, verbose).query

    def generate_random_integer(
        self, minimum: int, maximum: int, seed: Optional[int] = None
    ) -> int:
        """
        Generate a random integer N such that min <= N <= max.

        :param minimum: Number representing the minimum value
        :param maximum: Number representing the maximum value
        :param seed: Number to seed the random number generator. Default is
            ${none} in which case the current system time is used.
        """
        random.seed(seed)
        return random.randint(minimum, maximum)

    def encode_url(
        self, hostname: str, params: dict, verbose: bool = False
    ) -> str:
        """
        Encodes the URL and separates the URL parameters with specified separator
        set verbose to ${true} to show produced URL
        :return str
        """
        return utils.encode_url(hostname, params, verbose)
    