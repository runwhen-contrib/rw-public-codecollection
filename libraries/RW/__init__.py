"""
This line is required so that we can have RW.Core in one directory
and the other RW libs in other directories
See - https://packaging.python.org/en/latest/guides/packaging-namespace-packages/
"""
__path__ = __import__("pkgutil").extend_path(__path__, __name__)
