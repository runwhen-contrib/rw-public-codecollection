"""
DNS keyword library

Scope: Global
"""
import socket
import dns.resolver
from RW.Utils import utils
from typing import Optional


class DNS:
    """
    DNS keyword library
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def lookup(
        self,
        host: str,
        nameservers: Optional[str] = None,
        rtype: str = "A",
        verbose: bool = False,
    ) -> str:
        """
        DNS name lookup.

        Examples:
        | RW.DNS.Lookup | host=${HOSTNAME_TO_RESOLVE} | nameservers=8.8.8.8 |

        Return Value:
        | IP address |
        """
        if rtype not in ["A"]:
            NotImplementedError("Only A record is currently supported.")
        resolver = dns.resolver.Resolver()
        if nameservers is not None:
            nameservers = nameservers.split()
            resolver.nameservers = [
                socket.gethostbyname(n) for n in nameservers
            ]
        answer = resolver.resolve(host, rtype)
        addresses = [n.address for n in answer]
        if verbose:
            platform.debug_log(
                f"DNS lookup result: {addresses}", console=False
            )
        return addresses

    def lookup_latency_in_seconds(self, *args, **kwargs) -> float:
        """TBD"""
        latency, _ = utils.latency(
            self.lookup, *args, **kwargs, latency_params=[3, "s"]
        )
        return latency

    def lookup_latency_in_milliseconds(self, *args, **kwargs) -> float:
        """TBD"""
        latency, _ = utils.latency(
            self.lookup, *args, **kwargs, latency_params=[None, "ms"]
        )
        return latency
