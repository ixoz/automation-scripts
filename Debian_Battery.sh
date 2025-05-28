#!/bin/bash

# === CONFIG ===
BAT_PATH="/sys/class/power_supply/BAT1/charge_control_end_threshold"
THRESHOLD=60
BIN_SCRIPT="/usr/local/bin/set-battery-threshold.sh"
SERVICE_FILE="/etc/systemd/system/battery-threshold.service"
SLEEP_HOOK="/lib/systemd/system-sleep/set-battery-threshold"

echo "Setting up battery charge threshold to $THRESHOLD%..."

# 1. Create the battery threshold setting script
echo "Creating main script..."
cat <<EOF > "$BIN_SCRIPT"
#!/bin/bash
echo $THRESHOLD > $BAT_PATH
EOF

chmod +x "$BIN_SCRIPT"

# 2. Create the systemd service
echo "Creating systemd service..."
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Set battery charge threshold
After=suspend.target
Before=shutdown.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=$BIN_SCRIPT
RemainAfterExit=true

[Install]
WantedBy=multi-user.target suspend.target
EOF

# 3. Enable the service
echo "Enabling systemd service..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable battery-threshold.service
systemctl start battery-threshold.service

# 4. Create resume (sleep/wake) hook
echo "Creating sleep hook..."
cat <<EOF > "$SLEEP_HOOK"
#!/bin/bash
case \$1 in
  post)
    echo $THRESHOLD > $BAT_PATH
    ;;
esac
EOF

chmod +x "$SLEEP_HOOK"

# 5. Apply immediately
echo "Applying setting immediately..."
echo $THRESHOLD > $BAT_PATH

echo "Battery threshold set to $THRESHOLD% and will persist after reboot and lid open/close."
