"""
cert-manager keyword library, based on shellservice base.

Scope: Global
"""
import re, kubernetes, yaml
import dateutil.parser
import datetime
from benedict import benedict
from typing import Optional, Union
from RW import platform
from RW.K8s import K8s
from enum import Enum

class CertManager:
    """
    cert-manager keyword library can be used monitor and health check cert-manager resources.
    """
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self._k8s = K8s()
    def check_certificate_dates(
        self,
        days_left_allowed,
        kubeconfig,
        namespace,
        context=None,
        labels=None,
        field_selector=None,
        target_service: platform.Service = None,
    ):
        days_left_allowed = int(days_left_allowed)
        certs = self._k8s.get(
            kind="Certificate",
            api_version="cert-manager.io/v1",
            kubeconfig=kubeconfig,
            namespace=namespace,
            target_service=target_service,
        )
        certs_expiring = []
        if certs and "items" in certs:
            certs = certs["items"] if certs and "items" in certs else [certs]
            for cert in certs:
                cert = benedict(cert, keypath_separator=None)
                if ["status", "notAfter"] in cert:
                    expiry_date = dateutil.parser.parse(cert["status", "notAfter"])
                    today = dateutil.parser.parse(self.get_now())
                    diff_days = (expiry_date - today).days
                    if diff_days <= days_left_allowed:
                        certs_expiring.append(cert)
        return certs_expiring

    def get_now(self):
        return f"{datetime.datetime.utcnow().isoformat()}Z"

    def health_check(
        self,
        kubeconfig,
        namespace,
        context=None,
        labels=None,
        field_selector=None,
        target_service: platform.Service = None,
    ):
        cm_pods = self._k8s.get(
            kind="Pod",
            kubeconfig=kubeconfig,
            namespace=namespace,
            label_selector="app.kubernetes.io/instance=cert-manager",
            field_selector="status.phase=Running",
            target_service=target_service,
        )
        healthy = True
        if cm_pods and "items" in cm_pods:
            cm_pods = cm_pods["items"] if cm_pods and "items" in cm_pods else [cm_pods]
            for pod in cm_pods:
                pod = benedict(pod, keypath_separator=None)
                if ["status", "containerStatuses"] in pod:
                    for c_status in pod["status", "containerStatuses"]:
                        c_status = benedict(c_status, keypath_separator=None)
                        if (
                            c_status["ready"] is not True
                            or c_status["started"] is not True
                        ):
                            healthy = False
        return healthy
