"""
WebInspector keyword library

Scope: Global
"""
import ssl
import socket
import OpenSSL
import requests
import dns
import dns.resolver
from pprint import pprint
from datetime import datetime
from urllib.parse import urlparse

from RW import platform, restclient
from RW.Utils import utils

#TODO: refactor and move to new HTTP v2 module
class WebInspector:
    """The WebInspector keyword library is a set of functions that can be used to diagnose site issues."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        pass

    def verify_egress(self):
        results = self.get_latency_measurements(
            "https://www.google.com", num_requests=10
        )
        if len(results) > 0:
            return True

    def get_certificate(self, host, port=443, timeout=10) -> {}:
        result = {}
        context = ssl.create_default_context()
        conn = socket.create_connection((host, port))
        try:
            sock = context.wrap_socket(conn, server_hostname=host)
            sock.settimeout(timeout)
            der_cert = sock.getpeercert(True)
            sock.close()
            certificate = ssl.DER_cert_to_PEM_cert(der_cert)
            x509 = OpenSSL.crypto.load_certificate(
                OpenSSL.crypto.FILETYPE_PEM, certificate
            )
            result = {
                "subject": str(dict(x509.get_subject().get_components())),
                "issuer": str(dict(x509.get_issuer().get_components())),
                "serial_number": x509.get_serial_number(),
                "version": x509.get_version(),
                "not_before": x509.get_notBefore().decode("utf-8"),
                "not_after": x509.get_notAfter().decode("utf-8"),
            }
            extensions = (
                x509.get_extension(i)
                for i in range(x509.get_extension_count())
            )
            extension_data = {
                str(e.get_short_name()): str(e) for e in extensions
            }
            result.update(extension_data)
        except Exception as e:
            platform.debug_log(
                "Encountered error when inspect host certificate {host}:{port}: {e}"
            )
            result = {"error": str(e)}
        return result

    def get_latency_measurements(self, url, num_requests=30, timeout=30) -> {}:
        results = []
        for _ in range(num_requests):
            rsp = requests.get(url=url, timeout=timeout)
            result = {
                "latency": rsp.elapsed.total_seconds(),
                "status_code": rsp.status_code,
            }
            results.append(result)
        return results

    def get_dns_info(self, host, rtype="A", nameservers=["8.8.8.8"]):
        results = {}
        resolver = dns.resolver.Resolver()
        if nameservers is not None:
            resolver.nameservers = [
                socket.gethostbyname(n) for n in nameservers
            ]
        if rtype not in ["A", "CNAME", "CAA"]:
            NotImplementedError(
                f"Record type {rtype} not currently supported."
            )
        try:
            answer = resolver.resolve(host, rtype)
            results = {f"{rtype}_answers": [str(n) for n in answer]}
        except dns.resolver.NoAnswer:
            platform.debug_log(f"No answer from host: {host}")
            results = {
                "error": f"No answer from host: {host} with record type: {rtype}"
            }
        return results

    def get_cert_valid_from(self, inspection, date_format="%Y%m%d%H%M%SZ"):
        if (
            "error" in inspection["certificate_info"]
            or "not_before" not in inspection["certificate_info"]
        ):
            return "Certificate has error or is malformed"
        else:
            return datetime.strptime(
                inspection["certificate_info"]["not_before"], date_format
            )

    def get_cert_valid_until(self, inspection, date_format="%Y%m%d%H%M%SZ"):
        if (
            "error" in inspection["certificate_info"]
            or "not_after" not in inspection["certificate_info"]
        ):
            return "Certificate has error or is malformed"
        else:
            return datetime.strptime(
                inspection["certificate_info"]["not_after"], date_format
            )

    def inspect_url(self, url, request_count) -> dict:
        host = urlparse(url).netloc
        latency_results = self.get_latency_measurements(
            url, num_requests=int(request_count)
        )
        successes = [
            r
            for r in latency_results
            if r["status_code"] >= 200 and r["status_code"] < 300
        ]
        inspection = {
            "latency_info": {
                "average_latency": sum([v["latency"] for v in latency_results])
                / len(latency_results),
                "success_ratio": len(successes) / len(latency_results),
                "number_of_requests": len(latency_results),
                "results": latency_results,
            },
            "url": url,
            "dns_info": [
                self.get_dns_info(host, rtype=r) for r in ["A", "CNAME", "CAA"]
            ],
            "certificate_info": self.get_certificate(host),
        }
        return inspection
