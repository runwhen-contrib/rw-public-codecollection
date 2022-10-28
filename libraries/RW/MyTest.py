"""
MyTest keyword library

Scope: Global
"""
from RW.Utils import utils
from RW import platform


class MyTest:
    """MyTest keyword library is used for internal testing."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, counter: int = 0) -> None:
        self.counter = counter

    def my_test_kw(self) -> bool:
        """
        TBD
        """
        self.counter += 1
        platform.debug_log(f"In my_test_kw: counter={self.counter}")
        return True
