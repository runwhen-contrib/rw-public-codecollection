"""
MS Teams keyword library

Scope: Global
"""
import pymsteams


class MSTeams:
    """
    MS Teams keyword library can be used to send alerts/notifications
    to a channel in Teams.

    * You need to define a team in Microsoft 365, then this team will show up
      in MS Teams.
    * In MS Teams, select the team and create a channel for it.
    * In the channel, set up a Connector and choose Incoming Webhook.
    * After configuring the Incoming Webhook, you'll get a Webhook URL
      which can be used by pymsteams to send a message to the channel.

    See https://github.com/rveachkc/pymsteams for more information.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def send_message(self, msg: str, url: str) -> None:
        """
        Send a message to an MS Teams channel designated by the MS Teams Webhook URL.
        Examples:
        | Import User Variable    | MSTEAMS_ALERTS_CHANNEL_URL | |
        | RW.MSTeams.Send Message | Hello, World! | ${MSTEAMS_ALERTS_CHANNEL_URL} |
        """
        m = pymsteams.connectorcard(url)
        m.text(msg)
        m.send()
