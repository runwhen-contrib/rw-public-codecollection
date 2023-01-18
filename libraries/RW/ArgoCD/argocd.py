"""
Argocd keyword library

Scope: Global
"""
import time
from dataclasses import dataclass
from typing import Union, Optional
from RW import platform
from RW.K8s.k8s import K8s


class ArgoCD:
    """
    ArgoCD keyword library
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    ARGOCD_DEPLOYMENTS = [
        "argocd-applicationset-controller",
        "argocd-dex-server",
        "argocd-notifications-controller",
        "argocd-redis",
        "argocd-repo-server",
        "argocd-server",
    ]
    ARGOCD_STATEFULSETS = [
        "argocd-application-controller",
    ]

    def health_check(
        self,
        target_service: platform.Service,
        kubeconfig: platform.Secret,
        context: str,
        namespace: str = "argocd",
    ):
        health = True
        k8s: K8s = K8s()
        for deployment in ArgoCD.ARGOCD_DEPLOYMENTS:
            resource_status: bool = False
            stdout = k8s.shell(
                cmd=f"kubectl get deployment.apps/{deployment} --context={context} --namespace={namespace} -o jsonpath='{{.status.conditions[?(@.type==\"Available\")].status}}'",
                target_service=target_service,
                kubeconfig=kubeconfig,
            )
            if stdout == "True":
                resource_status = True
            health = health and resource_status
        for statefulset in ArgoCD.ARGOCD_STATEFULSETS:
            resource_status: bool = False
            stdout = k8s.shell(
                cmd=f"kubectl get statefulset.apps/{statefulset} --context={context} --namespace={namespace} -o jsonpath='{{.status.availableReplicas}}'",
                target_service=target_service,
                kubeconfig=kubeconfig,
            )
            # TODO: revisit replica availability edge cases
            if stdout and int(stdout) > 0:
                resource_status = True
            health = health and resource_status
        return health
