#!/bin/bash
# NetClientX Unified Installer
# Supported browsers: chromium, firefox

# Check if run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script with sudo."
    exit 1
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BROWSER=""
URL=""

# Helper function to print usage
print_usage() {
    echo "Usage: sudo ./netclientx.sh [chromium|firefox] [url]"
    echo "  Or:  sudo ./netclientx-chromium.sh [url]"
    echo "  Or:  sudo ./netclientx-firefox.sh [url]"
}

# Parse parameters
if [ "$1" = "chromium" ] || [ "$1" = "firefox" ]; then
    BROWSER=$1
    URL=$2
elif [ "$1" = "--browser" ] || [ "$1" = "-b" ]; then
    BROWSER=$2
    URL=$3
else
    URL=$1
fi

# If browser is not specified, ask interactively
if [ -z "$BROWSER" ]; then
    echo "Select the browser to install:"
    echo "1) Chromium (Default)"
    echo "2) Firefox"
    read -p "Choose option (1-2) [Default 1]: " BROWSER_OPT
    # If the user pressed enter without typing anything
    if [ -z "$BROWSER_OPT" ]; then
        BROWSER_OPT=1
    fi
    case "$BROWSER_OPT" in
        1) BROWSER="chromium" ;;
        2) BROWSER="firefox" ;;
        *) echo "Invalid option. Exiting."; exit 1 ;;
    esac
fi

if [ "$BROWSER" != "chromium" ] && [ "$BROWSER" != "firefox" ]; then
    echo "Error: Unsupported browser '$BROWSER'. Supported browsers are: chromium, firefox."
    print_usage
    exit 1
fi

# Prompt for URL if not provided
if [ -z "$URL" ]; then
    read -p "Enter connection URL [Default google.com]: " URL
    if [ -z "$URL" ]; then
        URL="google.com"
    fi
fi

# Clean and validate URL
URL=$(echo "$URL" | xargs)
if [ -z "$URL" ]; then
    echo "Error: URL cannot be empty."
    exit 1
fi
if [[ ! "$URL" =~ ^https?:// ]]; then
    URL="https://$URL"
fi

# GET USERNAME
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    USERNAME=$SUDO_USER
elif [ "$(logname 2>/dev/null)" ] && [ "$(logname 2>/dev/null)" != "root" ]; then
    USERNAME=$(logname)
else
    USERNAME=$(awk -F: '$3 >= 1000 && $3 != 65534 {print $1; exit}' /etc/passwd)
fi

if [ -z "$USERNAME" ] || [ "$USERNAME" = "root" ]; then
    echo "Error: Could not determine the non-root user."
    exit 1
fi

echo "=========================================="
echo " Starting NetClientX Setup"
echo " Target User: $USERNAME"
echo " Browser:     $BROWSER"
echo " Portal URL:  $URL"
echo "=========================================="

# UPDATE AND INSTALL SOFTWARE
echo "Installing packages..."
apt update && apt upgrade -y && apt autoremove -y

if [ "$BROWSER" = "chromium" ]; then
    apt install -y --no-install-recommends xorg openbox chromium-browser network-manager network-manager-gnome tint2 wget
else
    apt install -y --no-install-recommends xorg openbox firefox network-manager network-manager-gnome tint2 wget
fi

# DOWNLOAD RETRO FONT
echo "Downloading and setting up local font..."
mkdir -p /home/$USERNAME/fonts
wget -q "https://fonts.gstatic.com/s/vt323/v17/pxiKyp0ihIEF2isfFJU.woff2" -O /home/$USERNAME/fonts/VT323.woff2

# COPY AND CONFIGURE WAITING PAGE
echo "Setting up local waiting page..."
cp "$SCRIPT_DIR/waiting.html" "/home/$USERNAME/waiting.html"
sed -i "s|URL_PLACEHOLDER|$URL|g" "/home/$USERNAME/waiting.html"

# FIX PERMISSIONS & DOWNLOAD DIRECTORIES
chmod 644 /home/$USERNAME/waiting.html
chmod 644 /home/$USERNAME/fonts/VT323.woff2
chown -R $USERNAME:$USERNAME /home/$USERNAME/fonts /home/$USERNAME/waiting.html

# COPY OPENBOX SYSTEM MENU
echo "Setting up Openbox system menu..."
mkdir -p /home/$USERNAME/.config/openbox
cp "$SCRIPT_DIR/openbox/menu.xml" "/home/$USERNAME/.config/openbox/menu.xml"
chmod 644 /home/$USERNAME/.config/openbox/menu.xml
chown -R $USERNAME:$USERNAME /home/$USERNAME/.config

# SETUP AUTOLOGIN
echo "Setting up autologin..."
mkdir -p /etc/systemd/system/getty@tty1.service.d/
tee /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF

# X AUTOSTART
grep -qF 'startx' /home/$USERNAME/.bash_profile || cat >> /home/$USERNAME/.bash_profile <<EOF
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx
fi
EOF
chown $USERNAME:$USERNAME /home/$USERNAME/.bash_profile

# OPENBOX, BROWSER, TINT2 AND NM-APPLET AUTOSTART (.xinitrc)
echo "Setting up graphic session autostart..."
cat > /home/$USERNAME/.xinitrc <<EOF
openbox &
tint2 &
nm-applet &
while true; do
    if command -v chromium-browser &> /dev/null; then
        sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/g' /home/$USERNAME/.config/chromium/Default/Preferences 2>/dev/null
        chromium-browser --start-fullscreen --no-first-run --disable-session-crashed-bubble --restore-last-session=false file:///home/$USERNAME/waiting.html
    elif command -v firefox &> /dev/null; then
        firefox --kiosk file:///home/$USERNAME/waiting.html
    else
        sleep 5
    fi
    sleep 2
done
EOF
chmod 755 /home/$USERNAME/.xinitrc
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc

# AUTO UPDATE ON BOOT (Background, low priority, non-blocking)
echo "Setting up auto-updates service..."
tee /etc/systemd/system/autoupdate.service <<EOF
[Unit]
Description=Auto update on boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
Environment=DEBIAN_FRONTEND=noninteractive
Nice=19
IOSchedulingClass=idle
ExecStart=/usr/bin/apt-get update
ExecStart=/usr/bin/apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
ExecStartPost=/usr/bin/apt-get autoremove -y

[Install]
WantedBy=multi-user.target
EOF

# APPLY CHANGES
systemctl daemon-reload
systemctl enable autoupdate.service
apt-get autoremove -y

# REBOOT
echo "=========================================="
echo " Setup Finished! Rebooting system in 5s..."
echo "=========================================="
sleep 5
reboot
