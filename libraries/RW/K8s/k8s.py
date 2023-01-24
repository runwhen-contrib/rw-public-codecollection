"""
K8s keyword library, version 2, based on shellservice base.

Scope: Global
"""
import re, kubernetes, yaml, logging, json, jmespath
from struct import unpack
import dateutil.parser
from benedict import benedict
from typing import Optional, Union
from RW import platform
from RW.Utils import utils
from enum import Enum
from .namespace_tasks_mixin import NamespaceTasksMixin
from robot.libraries.BuiltIn import BuiltIn 

logger = logging.getLogger(__name__)

class K8s(
    NamespaceTasksMixin
    ):
    """
    K8s keyword library can be used to interact with Kubernetes clusters.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def compose_kubectl_cmd(
        self,
        kind: str,
        name: str = None,
        verb: str = "",
        verb_flags: str = "",
        label_selector: str = None,
        field_selector: str = None,
        context: str = None,
        namespace: str = None,
        output_format="yaml",
        binary_name: str="kubectl",
        **kwargs,
    ) -> str:
        command = []
        command.append(f"{binary_name}")
        if context:
            command.append(f"--context {context}")
        if namespace:
            command.append(f"--namespace {namespace}")

        if verb and verb_flags:
            command.append(f"{verb} {verb_flags}")
        elif verb:
            command.append(f"{verb}")

        if label_selector:
            command.append(f"--selector {label_selector}")

        if kind and name and not label_selector:
            command.append(f"{kind}/{name}")
        elif kind:
            command.append(f"{kind}")

        if field_selector:
            command.append(f"--field-selector {field_selector}")

        if output_format:
            command.append(f"-o {output_format}")
        return " ".join(command)
    def convert_to_metric(
        self,
        command: str=None,
        data: str=None,
        search_filter: str="",
        calculation_field: str="",
        calculation: str="Count"
    ) -> float:
        if utils.is_json(data) == False:
            raise ValueError(f"Error: Data does not appear to be valid json")
        else: 
            payload=json.loads(data)
            items=utils.search_json(data=payload, pattern="items[]")
        #BuiltIn().run_keyword("BuiltIn.Log", items)
        if search_filter: 
            search_results=utils.search_json(data=items, pattern=search_filter)
        else: 
            search_results=items
        if calculation == "Count":
            return len(search_results)
        if not calculation_field: 
            raise ValueError(f"Error: Calculation field must be set for calcluations that are sum or avg.")   
        if calculation == "Sum":
            metric = utils.search_json(data=payload, pattern="sum(items[]."+calculation_field+")")
            return float(metric)
        if calculation == "Avg":
            metric = utils.search_json(data=payload, pattern="avg(items[]."+calculation_field+")")
            return float(metric)