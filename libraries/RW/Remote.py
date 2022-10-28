import traceback, requests, re, os, yaml, urllib.parse, json
import kubernetes
from RW import platform


class RemoteException(BaseException):
    pass


class Remote:
    #TODO: Refactor for easier use
    ROBOT_LIBRARY_SCOPE = "SUITE"
    client_has_config = False
    remoter_name = "remoter"
    remoter_port = 8088

    def hello_world_message(self):
        return "hello world msg"

    def use_remoter(self, remoter_name: str = "remoter"):
        """If you'd like to use a remoter other than 'remoter', set this for global library
        state.  (This should generally come from an imported user variable.). This is for the
        case where a workspace has multiple remoters active.
        """
        if not remoter_name:
            raise ValueError(f"remoter_name can not be none, received {remoter_name}")
        self.remoter_name = remoter_name

    def remote_run(self, cmd: str = 'echo "hello world"', timeout=60):
        """Executes the cmd on the remoter, and returns a struct with keys stdout, stderr, rc
        or raises an RemoteExecption with a (potentially long) exception message from a runtime
        exception with the infrastructure in the middle.
        """
        qp = urllib.parse.urlencode({"cmd": cmd, "timeout": timeout})
        ns = self.kub_get_current_namespace()
        url = f"http://{self.remoter_name}.{ns}.svc.cluster.local:{self.remoter_port}?{qp}"
        rsp = requests.get(url, timeout=timeout)
        try:
            ro = rsp.json()
            if ro.get("exception"):
                e_str = json.dumps(ro.get("exception"), indent=2)
                raise RemoteException(
                    f"Exception while running cmd {cmd} on remoter {self.remoter_name}:\n{e_str}\n\nfull response:{rsp.text}"
                )
            return ro
        except json.JSONDecodeError as e:
            raise RemoteException(
                f"Error while parsing result of cmd {cmd} on remoter {self.remoter_name}:\n {rsp.text}"
            )

    def remote_check(self, cmd: str = 'echo "hello world"', timeout=60):
        """Executes the cmd on the remoter, and returns a struct with keys stdout, stderr.  If the returncode
        of the remote process was non-zero, or if anything else went awry, this raises an RemoteExecption
        with a (potentially long) exception message
        """
        ret = self.remote_run(cmd, timeout=timeout)
        if ret.get("rc") != 0:
            raise RemoteException(
                f"Non-zero response code from running {cmd} on {self.remoter_name}:\n{json.dumps(ret, indent=2)}"
            )
        return ret

    def remote_logs(self, tail=100, timeout=60):
        """Returns log lines from the remoter, a max of 'tail' number of lines, as an array of strings"""
        ret = self.remote_run(f"tail -{str(tail)} /tmp/rw/remoter.log", timeout=timeout)
        if ret.get("rc") != 0:
            raise RemoteException(
                f"Non-zero response code while trying to get logs from {self.remoter_name}:\n{json.dumps(ret, indent=2)}"
            )
        return ret.get("stdout").split("\n")

    def kub_get_current_namespace(self):
        """Returns the namespace where this is SLI/Runbook is currently operating"""
        ret = None
        with open("/var/run/secrets/kubernetes.io/serviceaccount/namespace") as f:
            ret = f.read()
        return ret
