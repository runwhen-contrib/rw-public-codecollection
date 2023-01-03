from time import sleep
from benedict import benedict
from RW.Utils.utils import yaml_to_dict

from RW import platform

class JobTasksMixin:
    def job_successful(
        self,
        job_name,
        namespace:str,
        context:str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        binary_name: str = "kubectl",
    ) -> bool:
        is_successful: bool = True
        job_yaml: str = self.shell(
            cmd=f"{binary_name} get job/{job_name} -n {namespace} --context {context} -oyaml",
            target_service=target_service,
            kubeconfig=kubeconfig,
        )
        job = yaml_to_dict(job_yaml)
        job: benedict = benedict(job, keypath_separator=None)
        if "failed" in job["status"] and int(job["status", "failed"]) > 0:
            return False
        if "conditions" not in job["status"]:
            return False
        conditions: list = job["status","conditions"]
        found_complete = False
        for condition in conditions:
            if condition["status"] == "True" and condition["type"] == "Complete":
                found_complete = True
        return is_successful and found_complete
    
    def wait_until_job_successful(
        self,
        job_name,
        namespace:str,
        context:str,
        kubeconfig: platform.Secret,
        target_service: platform.Service,
        retries: int=5,
        interval: int=5,
        binary_name: str = "kubectl",
    ) -> bool:
        for _ in range(retries):
            is_succeeded: bool = self.job_successful(
                job_name=job_name,
                namespace=namespace,
                context=context,
                kubeconfig=kubeconfig,
                target_service=target_service,
                binary_name=binary_name,
            )
            if is_succeeded:
                return True
            sleep(interval)
        return False
