"""
K8s util library for k8s specific formatting and other tools.

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

logger = logging.getLogger(__name__)

class K8sUtils():
    """
    K8s utils to help format K8s output.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    
    def convert_to_metric(
        command: str=None,
        data: str=None,
        search_filter: str="",
        calculation_field: str="",
        calculation: str="Count"
    ) -> float:
        """Takes in a json data result from kubectl and calculation parameters to return a single float metric. 
        Assumes that the return is a "list" type and automatically searches through the "items" list, along with 
        other search filters provided buy the user (using jmespath search).

        Args: 
            :data str: JSON data to search through. 
            :command str: The command used to generate the output (might be useful in expanding this function)
            :search_filter str: A jmespah filter used to help filter search results. See https://jmespath.org/? to test search strings.
            :calculation_field str: The field from the json output that calculation should be performed on/with. 
            :calculation_type str:  The type of calculation to perform. count, sum, avg. 
            :return: A float that represents the single calculated metric. 

        """
        if utils.is_json(data) == False:
            raise ValueError(f"Error: Data does not appear to be valid json")
        else: 
            payload=json.loads(data)
        
        # Set search prefix to narrow down results and to support simpler user input.
        if search_filter: 
            search_pattern_prefix="items[?"+search_filter+"]"
            search_results=utils.search_json(data=payload, pattern=search_pattern_prefix)
        else: 
            search_pattern_prefix="items[]"
            search_results=utils.search_json(data=payload, pattern="items[]")
        
        # Return count of objects if specified. 
        if calculation == "Count":
            return len(search_results)


        if not calculation_field: 
            raise ValueError(f"Error: Calculation field must be set for calcluations that are sum or avg.")
        
        # Check if calculation field contains rults as well as anything but a number
        value_test = utils.search_json(data=payload, pattern=search_pattern_prefix+"."+calculation_field)
        if len(value_test) == 0:
            raise ValueError(f"Error: Could not find value at calculation field.")
        if re.match("\D", str(value_test[0])):
            raise ValueError(f"Error: Calculation field contains string. Field must only contain values. Please verify the desired calculation field.")

        # Perform calculations
        if calculation == "Sum":            
            metric = utils.search_json(data=payload, pattern="sum("+search_pattern_prefix+"."+calculation_field+")")
            return float(metric)
        if calculation == "Avg":
            metric = utils.search_json(data=payload, pattern="avg("+search_pattern_prefix+"."+calculation_field+")")
            return float(metric)
