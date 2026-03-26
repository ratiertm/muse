import json
import urllib.request
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

WEBHOOK_URL = "https://discord.com/api/webhooks/1486854494229893223/zHqs7FNOI_l3VTvB7eTMdNn5qGVcrsezdoeWjB4_uV_x41naXYus7H2Vcb9sSCO-ssgl"


def send_discord_alert(message: str):
    try:
        data = json.dumps({"content": message}).encode("utf-8")
        req = urllib.request.Request(
            WEBHOOK_URL, data=data,
            headers={"Content-Type": "application/json", "User-Agent": "Muse-Bot/1.0"}
        )
        urllib.request.urlopen(req, timeout=5)
    except Exception as e:
        logger.error(f"Discord notify failed: {e}")


def notify_500_error(method: str, path: str, error: str):
    now = datetime.now().strftime("%H:%M:%S")
    msg = f"\U0001f534 [{now}] API 500 error\n**{method} {path}**\n```{error[:500]}```"
    send_discord_alert(msg)
