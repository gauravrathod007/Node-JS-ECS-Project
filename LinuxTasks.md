This file contains your Linux-based tasks:
- Bash scripting
- Troubleshooting
- Security hardening

---

### 🧾 `LinuxTasks.md`

```markdown
# 🐧 Linux Administration & Security Tasks

---

## 🧮 1. Bash Scripting Task — Disk Usage Monitoring

#!/bin/bash
#
# check_disk_usage.sh
#
# Description:
#   This script checks system disk usage and reports any filesystem
#   whose usage exceeds a specified threshold (default 80%).
#   It logs output to /var/log/disk_usage_report.log and prints a summary.
#
# Usage:
#   ./check_disk_usage.sh [threshold]
#   Example: ./check_disk_usage.sh 85
#
# Author: Gaurav Rathod
# Date: 2025-11-03

# -------------------------------
# Configurable variables
# -------------------------------
THRESHOLD=${1:-80}    # Default threshold = 80% if not passed as argument
LOG_FILE="/var/log/disk_usage_report.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

# -------------------------------
# Ensure the script is run as root (optional but recommended)
# -------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "⚠️  Please run this script as root or with sudo privileges."
  exit 1
fi

# -------------------------------
# Function to check disk usage
# -------------------------------
check_disks() {
  echo "[$DATE] Starting disk usage check..." | tee -a "$LOG_FILE"
  echo "Threshold: $THRESHOLD%" | tee -a "$LOG_FILE"
  echo "----------------------------------------" | tee -a "$LOG_FILE"

  # Use df to get filesystem, usage percentage, and mount point
  df -hP | awk 'NR>1 {print $1, $5, $6}' | while read -r fs usage mountpoint; do
    # Remove % sign from usage value
    usage_percent=${usage%\%}

    if [[ $usage_percent -ge $THRESHOLD ]]; then
      echo "🚨 ALERT: $fs mounted on $mountpoint is ${usage_percent}% full!" | tee -a "$LOG_FILE"
      ALERT_FLAG=1
    else
      echo "✅ OK: $fs mounted on $mountpoint is ${usage_percent}% used." >> "$LOG_FILE"
    fi
  done

  echo "----------------------------------------" | tee -a "$LOG_FILE"
  echo "[$DATE] Disk check complete." | tee -a "$LOG_FILE"
}

# -------------------------------
# Function to summarize results
# -------------------------------
summary() {
  echo
  if [[ $ALERT_FLAG -eq 1 ]]; then
    echo "⚠️  Some partitions exceeded ${THRESHOLD}% usage! Check $LOG_FILE for details."
  else
    echo "✅ All disks are under ${THRESHOLD}% usage."
  fi
}

# -------------------------------
# Main execution
# -------------------------------
ALERT_FLAG=0
check_disks
summary
exit 0

## 🧮 2. Troubleshooting Scenario — Web Service Not Starting

Step-by-step Approach

Check Service Status
sudo systemctl status service

**Common Causes**

Invalid or unreadable configuration
Permission errors
Port conflicts
Missing dependencies
SELinux/AppArmor denials

## 🧮 3. Security Hardening on Linux
(A) SSH Hardening

File: /etc/ssh/sshd_config

PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
AllowUsers ubuntu deployuser

sudo systemctl restart ssh

(B) Firewall Configuration with ufw

Allow only necessary ports:

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from <your_ip> to any port 22 proto tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status numbered

Expected Output:

22/tcp  ALLOW  IP
80/tcp  ALLOW  Anywhere
443/tcp ALLOW  Anywhere
