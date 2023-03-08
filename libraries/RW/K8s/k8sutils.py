"""
K8s util library for k8s specific formatting and other tools.

Scope: Global
"""
import re, kubernetes, yaml, logging, json, jmespath
from struct import unpack
import dateutil.parser
from datetime import datetime, timedelta
from benedict import benedict
from typing import Optional, Union
from RW import platform
from RW.Utils import utils
from enum import Enum
from robot.libraries.BuiltIn import BuiltIn

logger = logging.getLogger(__name__)

class K8sUtils:
    """
    K8s helper functions.
    """
    # TODO: add in original command to help with utils that parse various command details. Not yet needed - but projected to be useful. 

    @staticmethod
    def convert_to_metric(
        data: str="",
        search_filter: str="",
        calculation_field: str="",
        calculation: str="Count"
    ) -> float:
        """Takes in a json data result from kubectl and calculation parameters to return a single float metric. 
        Assumes that the return is a "list" type and automatically searches through the "items" list, along with 
        other search filters provided buy the user (using jmespath search).

        Args: 
            :data str: JSON data to search through. 
            :search_filter str: A jmespah filter used to help filter search results. See https://jmespath.org/? to test search strings.
            :calculation_field str: The field from the json output that calculation should be performed on/with. 
            :calculation_type str:  The type of calculation to perform. count, sum, avg. 
            :return: A float that represents the single calculated metric. 

        """
        if utils.is_json(data) == False:
            raise ValueError(f"Error: Data does not appear to be valid json")
        else: 
            payload=json.loads(data)
        # Log search filter - keep this so that useres can validate their patterns with jmespath
        BuiltIn().run_keyword('Log', search_filter)

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
        
        # Check if calculation field contains results as well as anything but a number
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

    def convert_age_to_search_time (age) -> str: 
        current_time = datetime.now()
        time_values={
            'days': {'short': 'd', 'long': 'days', 'value': 0},
            'hours': {'short': 'h', 'long': 'hours', 'value': 0},
            'minutes': {'short': 'm', 'long': 'minutes', 'value': 0}
        }
        for item_name, item_details in time_values.items(): 
            if item_details['short'] in age:  
                age = int(age.split(item_details['short'])[0])
                time_values[item_name]['value'] = age
                break
        search_time = current_time - timedelta(days=time_values['days']['value'], hours=time_values['hours']['value'], minutes=time_values['minutes']['value']) 
        return search_time.strftime('%Y-%m-%dT%H:%M:%SZ')

    def jmespath_namespace_search_string (namespaces) -> str: 
        namespace_list=namespaces.split(',')
        for num,namespace_name in enumerate(namespace_list):
            namespace_list[num]=f"metadata.namespace == `{namespace_name}`" 
        namespace_search_string=' || '.join(namespace_list)
        return namespace_search_string
        