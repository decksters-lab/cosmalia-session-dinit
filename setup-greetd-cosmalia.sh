#!/bin/bash
# setup-greetd-cosmalia.sh - Configure greetd with cosmic-greeter for Cosmalia session selection

set -euo pipefail

CONFIG="/etc/greetd/config.toml"

echo "Configuring greetd to use cosmic-greeter with session selection..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (use sudo)"
    exit 1
fi

# Backup existing config
if [ -f "$CONFIG" ]; then
    cp "$CONFIG" "$CONFIG.bak.$(date +%s)"
    echo "Backed up existing config"
fi

# Write new config - use cosmic-greeter-start which runs cosmic-comp + cosmic-greeter
cat > "$CONFIG" << 'EOF'
[terminal]
vt = 1

[default_session]
command = "cosmic-greeter-start"
user = "cosmic-greeter"
service = "greetd-greeter"
EOF

echo "Updated $CONFIG"

# Restart greetd
if dinitctl status greetd >/dev/null 2>&1; then
    dinitctl restart greetd
    echo "Restarted greetd"
else
    echo "greetd not loaded, starting..."
    dinitctl start greetd
fi

echo ""
echo "Done! At the login screen:"
echo "  cosmic-greeter will show session selection from /usr/share/wayland-sessions/"
echo "  Cosmalia will appear as an option"
echo ""
echo "Cosmalia desktop file: /usr/share/wayland-sessions/cosmalia.desktop"