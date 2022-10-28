"""
Discord keyword library

Scope: Global
"""
import aiohttp
import asyncio
from discord import Webhook, AsyncWebhookAdapter
from typing import Union, Optional
from RW.Utils import utils


class Discord:
    """
    Discord keyword library can be used to send notifications
    to a channel in Discord.

    * Create a Discord server.
    * Create a channel (e.g., #alerts) and a webhook for the Discord server.
    * Send a message to the channel using the webhook URL.

    See https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks for more information.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def send_message(
        self,
        msg: str,
        url: str,
        user: Optional[str] = None,
        verbose: Union[str, bool] = False,
    ) -> None:
        """
        Send a message to the Discord server.
        Examples:
        | Import User Variable | DISCORD_ALERTS_CHANNEL_URL |
        | RW.Discord.Send Message | Red alert (sent by Discord Bot via Webhook)!!! | url=${DISCORD_ALERTS_CHANNEL_URL} |
        """
        verbose = utils.to_bool(verbose)
        if verbose is True:
            platform.debug_log(f"message: {msg}")
            platform.debug_log(f"webhook_url: {url}")

        async def send_m(l_msg, l_url, l_user):
            res = None
            async with aiohttp.ClientSession() as session:
                webhook = Webhook.from_url(
                    l_url, adapter=AsyncWebhookAdapter(session)
                )
                res = await webhook.send(l_msg, username=l_user, wait=True)
            return res

        loop = asyncio.get_event_loop()
        res = loop.run_until_complete(send_m(msg, url, user))
        if verbose is True:
            platform.debug_log(f"id: {res.id}", console=True)
            platform.debug_log(f"webhook_id: {res.webhook_id}", console=True)
            platform.debug_log(f"content: {res.content}", console=True)
            platform.debug_log(f"author: {res.author}", console=True)
            platform.debug_log(f"created_at: {res.created_at}", console=True)
