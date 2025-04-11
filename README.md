# InfraMonitorNginx 🚀

[![Bash](https://img.shields.io/badge/Bash-✓-lightgrey.svg)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/amir-zangiabadi/InfraMonitorNginx.svg)](https://github.com/amir-zangiabadi/InfraMonitorNginx/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/amir-zangiabadi/InfraMonitorNginx.svg)](https://github.com/amir-zangiabadi/InfraMonitorNginx/commits/main)

**InfraMonitorNginx** is a powerful, yet lightweight Bash script designed to monitor the health and performance of your infrastructure with a focus on Nginx servers. Whether you're a system administrator, DevOps engineer, or developer managing production environments, this script helps you gain real-time visibility into your servers and notifies you instantly when issues arise.

> **Repository:** [InfraMonitorNginx](https://github.com/amir-zangiabadi/InfraMonitorNginx.git)

---

## Features ✨

- ✅ Monitor Nginx service status
- ✅ Scan Nginx error and access logs for issues (500, 502, 503 errors)
- ✅ Check upstream server availability
- ✅ Verify critical ports (80/443) are open
- ✅ Track active HTTP/HTTPS connections
- ✅ Monitor CPU and RAM usage with configurable thresholds
- ✅ Send instant API notifications when problems are detected
- ✅ Clean, easy-to-read log files
- ✅ Simple to customize and extend

---

## Prerequisites 📋

Before using this script, ensure you have the following:

- Bash 4+
- `curl` for API requests
- `net-tools` (for `netstat` command)
- `sysstat` (for `mpstat` command)
- `nc` (netcat for port checks)
- Permissions to read server logs and run system commands

---

## Installation 🛠️

Clone the repository to your server:

```bash
git clone https://github.com/amir-zangiabadi/InfraMonitorNginx.git
cd InfraMonitorNginx
```

Make the script executable:

```bash
chmod +x InfraMonitorNginx.sh
```

---

## Configuration ⚙️

Open the script `InfraMonitorNginx.sh` in your preferred editor and update the configuration variables at the top of the file:

```bash
# Thresholds for alerts
CPU_THRESHOLD=80
RAM_THRESHOLD=80
CONNECTION_WARN_THRESHOLD=100
CONNECTION_CRITICAL_THRESHOLD=300

# API Credentials and URL
API_URL="http://YOUR_API_URL/api"
USERNAME="YOUR_USERNAME"
PASSWORD="YOUR_PASSWORD"
MESSAGE_THREAD_ID="YOUR_MESSAGE_THREAD_ID"

# Upstream servers to monitor
UPSTREAM_SERVERS=(
  "SERVER_IP_1:PORT"
  "SERVER_IP_2:PORT"
)
```

💡 **Tip:** Replace placeholder values with your actual server and API information.

---

## Usage 🚀

Run the script manually:

```bash
./InfraMonitorNginx.sh
```

The script will perform all health checks and send a notification if any issues are found.

---

## Automation ⏰

To automate monitoring, add the script to your crontab:

```bash
crontab -e
```

Example to run every 5 minutes:

```bash
*/5 * * * * /path/to/InfraMonitorNginx/InfraMonitorNginx.sh
```

This ensures continuous monitoring without manual intervention.

---

## Logging 🧾

All actions and detected issues are logged to:

```
/var/log/monitoring_script.log
```

Review this log regularly to understand server behavior and script activities.

---

## Customization 🛠️

This script is built for flexibility. You can:

- Add new health checks (e.g., disk space, database status)
- Integrate with other APIs or notification platforms (Slack, Telegram, etc.)
- Customize the message format for better readability
- Improve error handling and reporting as per your needs

Feel free to fork and enhance it!

---

## Troubleshooting 🐛

- **No notifications received?**
  - Check API credentials and URL.
  - Ensure your network allows outbound HTTP requests.

- **Permission denied errors?**
  - Ensure the script has execution permission: `chmod +x InfraMonitorNginx.sh`
  - Check if the user running the script has sufficient privileges.

- **Logs not generated?**
  - Verify that the script has write access to `/var/log/monitoring_script.log`.

If you encounter issues, feel free to open an issue in the [GitHub Issues](https://github.com/amir-zangiabadi/InfraMonitorNginx/issues) section.

---

## Contributing 🤝

Contributions are welcome! If you have improvements, please:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Let's build a better monitoring tool together!

---

## Important Note on Messaging API 📡

This script currently uses a custom **Telegram-compatible API** developed by the project author to send notifications. 

If you want to use this script for your own projects, you have two options:

1. **Use the same approach:** Write your own API service that interfaces with Telegram Bot API to receive messages from this script.
2. **Direct Telegram integration:** Modify the script to call the official Telegram Bot API directly, bypassing the need for an intermediate service.

> **Recommendation:** If you are not familiar with writing your own API, using Telegram's official Bot API is a fast and easy way to get started. You only need to create a bot, get the token, and update the script accordingly.

---

## License 📝

This project is licensed under the MIT License - see the [LICENSE](https://opensource.org/licenses/MIT) file for details.

---

## Final Words 🌟

Stay ahead of server issues and keep your infrastructure healthy with **InfraMonitorNginx**. Reliable monitoring leads to better uptime and peace of mind.

Happy monitoring! 🚀

