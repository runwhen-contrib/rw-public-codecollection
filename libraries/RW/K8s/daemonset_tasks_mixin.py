import logging
from benedict import benedict
from RW.Utils.utils import parse_numerical


logger = logging.getLogger(__name__)


class DaemonsetTasksMixin:
    def healthcheck_daemonset(self, daemonset):
        daemonset = benedict(daemonset, keypath_separator=None)
        current_number_scheduled = None
        desired_number_scheduled = None
        number_available = None
        # number of daemonsets on nodes that should not be
        number_misscheduled = None
        number_ready = None

        current_number_scheduled = daemonset["status", "currentNumberScheduled"]
        desired_number_scheduled = daemonset["status", "desiredNumberScheduled"]
        number_available = daemonset["status", "numberAvailable"]
        number_misscheduled = daemonset["status", "numberMisscheduled"]
        number_ready = daemonset["status", "numberReady"]

        max_unavailable = None
        try:
            mu = daemonset["spec", "updateStrategy", "rollingUpdate", "maxUnavailable"]
            max_unavailable = mu
        except:
            logger.info(f"Could not retreive updateStrategy.rollingUpdate.maxUnavailable from {daemonset}")
        number_unavailable = None
        try:
            nu = daemonset["status", "numberUnavailable"]
            number_unavailable = nu
        except:
            logger.info(f"Could not retreive status.numberUnavailable from {daemonset}")

        # we should not have above our max_unavailable
        if max_unavailable and number_unavailable and number_unavailable > max_unavailable:
            return False
        # we should have 0 mischeduled daemonset pods
        if number_misscheduled > 0:
            return False
        # current should be >= desired-max_unavailable
        if max_unavailable and current_number_scheduled < (desired_number_scheduled - max_unavailable):
            return False
        # ready, available, and current should be equal, indicating a successful pod rollout
        if current_number_scheduled != number_ready or number_ready != number_available:
            return False

        return True