#!/bin/bash

# ===========================================
# Public Monitoring Script Template
# Fill the configuration section with your own data.
# ===========================================

# ================== CONFIG ==================

# Thresholds (adjust as needed)
CPU_THRESHOLD=80
RAM_THRESHOLD=80
CONNECTION_WARN_THRESHOLD=100
CONNECTION_CRITICAL_THRESHOLD=300

# Message Thread ID (fill with your platform's thread ID)
MESSAGE_THREAD_ID="YOUR_MESSAGE_THREAD_ID"

# API Configuration
API_URL="http://YOUR_API_URL/api"
USERNAME="YOUR_USERNAME"
PASSWORD="YOUR_PASSWORD"

# Log file path
LOG_FILE="/var/log/monitoring_script.log"

# Define your upstream servers (IP:PORT)
UPSTREAM_SERVERS=(
  "SERVER_IP_1:PORT"
  "SERVER_IP_2:PORT"
  "SERVER_IP_3:PORT"
)

TOKEN=""  # Global token variable (do not change)

# ================== FUNCTIONS ==================

log() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

get_access_token() {
  if [[ -z "$TOKEN" ]]; then
    local response
    response=$(curl -s -X POST -H "Content-Type: application/json" \
      -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" \
      "$API_URL/getaccesstoken")

    TOKEN=$(echo "$response" | grep -oP '(?<="token":")[^"]+')

    if [[ -n "$TOKEN" ]]; then
      log "✅ Access token retrieved."
    else
      log "❌ Failed to retrieve access token."
    fi
  fi
}

send_message() {
  local message="$1"

  if [[ -z "$TOKEN" ]]; then
    get_access_token
    if [[ -z "$TOKEN" ]]; then
      log "❌ Cannot send message, token retrieval failed."
      return
    fi
  fi

  curl -s -X POST -H "Content-Type: application/json" \
       -H "Authorization: Bearer $TOKEN" \
       -d "{\"text\": \"$message\", \"messageThreadId\": $MESSAGE_THREAD_ID}" \
       "$API_URL/sendMessage"
}

escape_message() {
  echo "$1" | sed ':a;N;$!ba;s/\n/\\n/g'
}

get_ip_address() {
  hostname -I | awk '{print $1}'
}

convert_mb_to_gb() {
  awk "BEGIN {printf \"%.2f\", $1/1024}"
}

get_tehran_time() {
  TZ='Asia/Tehran' date '+%Y-%m-%d %H:%M:%S'
}

# ================== MAIN ==================

log "🔍 Monitoring script started."

current_time=$(get_tehran_time)
ip_address=$(get_ip_address)
hostname_name=$(hostname)

issues_found=false

# Check Nginx Status
if systemctl is-active --quiet nginx; then
  nginx_status="✅ Nginx is running."
else
  nginx_status="🚨 Nginx is *NOT* running!"
  issues_found=true
fi
log "$nginx_status"

# Check Nginx Error Logs
error_logs=$(journalctl -u nginx --since "10 minutes ago" | grep -i "error")
if [[ -n "$error_logs" ]]; then
  nginx_errors="🚨 Errors found in Nginx logs!"
  issues_found=true
else
  nginx_errors="✅ No errors in Nginx logs."
fi
log "$nginx_errors"

# Check Nginx Access Logs
access_log_errors=$(tail -n 1000 /var/log/nginx/access.log | grep -E " 500 | 502 | 503 ")
if [[ -n "$access_log_errors" ]]; then
  access_errors="🚨 Errors in access.log (500/502/503)!"
  issues_found=true
else
  access_errors="✅ No critical errors in access.log."
fi
log "$access_errors"

# Check Upstream Servers
upstream_status=""
for server in "${UPSTREAM_SERVERS[@]}"; do
  if nc -zv $(echo $server | tr ':' ' ') &>/dev/null; then
    upstream_status+="🔄 Upstream $server is reachable.\n"
  else
    upstream_status+="🚨 Upstream $server is *NOT* reachable!\n"
    issues_found=true
  fi
done
log "Upstream status checked."

# Check Nginx Ports
port_status=""
for port in 80 443; do
  if nc -zv 127.0.0.1 $port &>/dev/null; then
    port_status+="🔓 Port $port is open.\n"
  else
    port_status+="🚨 Port $port is *CLOSED*!\n"
    issues_found=true
  fi
done
log "Port status checked."

# Check Active Connections
active_connections=$(netstat -an | grep -E ':80 |:443 ' | wc -l)
if (( active_connections > CONNECTION_CRITICAL_THRESHOLD )); then
  connection_status="🚨 High number of active connections: *$active_connections*"
  issues_found=true
elif (( active_connections > CONNECTION_WARN_THRESHOLD )); then
  connection_status="⚠️ Warning: Elevated active connections: *$active_connections*"
  issues_found=true
else
  connection_status="✅ Active connections normal: *$active_connections*"
fi
log "$connection_status"

# Check CPU Usage
cpu_usage=$(mpstat 1 1 | awk '/Average/ && $NF ~ /[0-9.]+/ {print int(100 - $NF)}')
if (( cpu_usage > CPU_THRESHOLD )); then
  cpu_status="🚨 High CPU usage: *$cpu_usage%*"
  issues_found=true
else
  cpu_status="✅ CPU usage normal: *$cpu_usage%*"
fi
log "$cpu_status"

# Check RAM Usage
ram_info=$(free -m | awk '/Mem/ {print $3, $2}')
used_ram_mb=$(echo $ram_info | awk '{print $1}')
total_ram_mb=$(echo $ram_info | awk '{print $2}')
ram_usage_percent=$(( (used_ram_mb * 100) / total_ram_mb ))
used_ram_gb=$(convert_mb_to_gb $used_ram_mb)
total_ram_gb=$(convert_mb_to_gb $total_ram_mb)
if (( ram_usage_percent > RAM_THRESHOLD )); then
  ram_status="🚨 High RAM usage: *$ram_usage_percent%* (${used_ram_gb}GB/${total_ram_gb}GB)"
  issues_found=true
else
  ram_status="✅ RAM usage normal: *$ram_usage_percent%* (${used_ram_gb}GB/${total_ram_gb}GB)"
fi
log "$ram_status"

# Compose Final Message
full_message="🛠️ *Monitoring Report* 🕒 $current_time (Tehran Time)

🔎 IP Address: $ip_address
🏛️ Hostname: $hostname_name

$nginx_status
$nginx_errors
$access_errors
$upstream_status
$port_status
$connection_status
$cpu_status
$ram_status
"

escaped_message=$(escape_message "$full_message")

log "Sending monitoring report..."
send_message "$escaped_message"
log "✅ Monitoring report sent successfully."

exit 0
