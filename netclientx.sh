#!/bin/bash
# NetClientX Unified Installer
# Supported browsers: chromium, firefox

# Check if run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script with sudo."
    exit 1
fi

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
    # Wait for 10 seconds, then fallback to Chromium (Option 1)
    if ! read -t 10 -p "Choose option (1-2) [Default 1]: " BROWSER_OPT; then
        echo ""
        echo "Timeout reached. Selecting Chromium automatically."
        BROWSER_OPT=1
    fi
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
    if ! read -t 15 -p "Enter connection URL [Default google.com in 15s]: " URL; then
        echo ""
        echo "Timeout reached. Selecting google.com automatically."
        URL="google.com"
    fi
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

# GENERATE WAITING PAGE
echo "Generating local waiting page..."
cat > /home/$USERNAME/waiting.html << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>NetClientX</title>
  <style>
    @font-face {
      font-family: 'VT323';
      src: url('fonts/VT323.woff2') format('woff2');
    }
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #0a0000; overflow: hidden; font-family: 'VT323', monospace; transition: background 0.8s; }
    canvas { position: fixed; inset: 0; z-index: 0; }
    .wrapper {
      position: relative; z-index: 2;
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      min-height: 100vh; gap: 1.5rem; text-align: center; padding: 2rem;
    }
    .logo {
      font-family: 'VT323', monospace; font-weight: normal;
      font-size: clamp(3rem, 10vw, 6rem);
      letter-spacing: 0.15em; text-transform: uppercase;
      color: #fff; text-shadow: 0 0 20px rgba(255,0,0,0.8);
      transition: text-shadow 0.8s;
    }
    .logo span { color: #ff0000; transition: color 0.8s; }
    .status {
      font-size: clamp(1.2rem, 3vw, 1.6rem);
      letter-spacing: 0.25em; text-transform: uppercase;
      color: rgba(255,60,60,0.7); transition: opacity 0.6s, color 0.6s;
    }
    .dot { animation: blink 1s step-end infinite; }
    @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0} }
  </style>
</head>
<body>
<canvas id="bg"></canvas>
<div class="wrapper">
  <div class="logo" id="logo">NetClient<span id="accent">X</span></div>
  <div class="status" id="statusText">Waiting for connection<span class="dot">_</span></div>
</div>
<script>
  const TARGET_URL = "$URL";
  const canvas = document.getElementById('bg');
  const ctx = canvas.getContext('2d');
  let W, H, y1, y2;
  let bgColor = [10, 0, 0];
  let scanColor = [255, 0, 0];
  function resize() {
    W = canvas.width = window.innerWidth;
    H = canvas.height = window.innerHeight;
    y1 = 0; y2 = H * 0.4;
  }
  function draw() {
    ctx.fillStyle = 'rgb(' + bgColor[0] + ',' + bgColor[1] + ',' + bgColor[2] + ')';
    ctx.fillRect(0, 0, W, H);
    for (let y = 0; y < H; y += 4) {
      ctx.fillStyle = 'rgba(' + scanColor[0] + ',' + scanColor[1] + ',' + scanColor[2] + ',0.04)';
      ctx.fillRect(0, y, W, 1);
    }
    const b1 = ctx.createLinearGradient(0, y1 - 40, 0, y1 + 40);
    b1.addColorStop(0, 'transparent');
    b1.addColorStop(0.5, 'rgba(' + scanColor[0] + ',' + scanColor[1] + ',' + scanColor[2] + ',0.3)');
    b1.addColorStop(1, 'transparent');
    ctx.fillStyle = b1;
    ctx.fillRect(0, y1 - 40, W, 80);
    const b2 = ctx.createLinearGradient(0, y2 - 20, 0, y2 + 20);
    b2.addColorStop(0, 'transparent');
    b2.addColorStop(0.5, 'rgba(' + scanColor[0] + ',' + scanColor[1] + ',' + scanColor[2] + ',0.12)');
    b2.addColorStop(1, 'transparent');
    ctx.fillStyle = b2;
    ctx.fillRect(0, y2 - 20, W, 40);
    if (Math.random() > 0.93) {
      const gy = Math.random() * H;
      ctx.fillStyle = 'rgba(' + scanColor[0] + ',' + scanColor[1] + ',' + scanColor[2] + ',' + (Math.random() * 0.25) + ')';
      ctx.fillRect(0, gy, W, Math.random() * 2 + 1);
    }
    y1 = (y1 + 1.5) % H;
    y2 = (y2 + 0.8) % H;
    requestAnimationFrame(draw);
  }
  window.addEventListener('resize', resize);
  resize(); draw();
  const logo = document.getElementById('logo');
  const accent = document.getElementById('accent');
  const statusText = document.getElementById('statusText');
  let connected = false;
  let redirectTimer = null;
  function lerp(a, b, t) { return a + (b - a) * t; }
  function animateColor(from, to, duration) {
    const start = performance.now();
    function step(now) {
      const t = Math.min((now - start) / duration, 1);
      bgColor = [Math.round(lerp(from[0], to[0], t)), Math.round(lerp(from[1], to[1], t)), Math.round(lerp(from[2], to[2], t))];
      scanColor = bgColor[0] > bgColor[1] ? [255, 0, 0] : [0, 255, 65];
      if (t < 1) requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
  }
  function setStatus(state) {
    statusText.style.opacity = '0';
    setTimeout(() => {
      if (state === 'waiting' || state === 'lost') {
        animateColor(bgColor, [10, 0, 0], 800);
        logo.style.textShadow = '0 0 20px rgba(255,0,0,0.8)';
        accent.style.color = '#ff0000';
        statusText.style.color = 'rgba(255,60,60,0.7)';
        statusText.innerHTML = state === 'lost' ? 'Connection lost<span class="dot">_</span>' : 'Waiting for connection<span class="dot">_</span>';
      } else if (state === 'established') {
        animateColor(bgColor, [0, 10, 0], 800);
        logo.style.textShadow = '0 0 20px rgba(0,255,80,0.8)';
        accent.style.color = '#00ff41';
        statusText.style.color = 'rgba(60,255,100,0.9)';
        statusText.innerHTML = 'Connection established<span class="dot">_</span>';
      }
      statusText.style.opacity = '1';
    }, 400);
  }
  function checkConnection() {
    fetch('https://clients3.google.com/generate_204', { mode: 'no-cors', cache: 'no-store' })
      .then(() => {
        if (!connected) {
          connected = true;
          setStatus('established');
          redirectTimer = setTimeout(() => { window.location.href = TARGET_URL; }, 3000);
        }
      })
      .catch(() => {
        if (connected) {
          connected = false;
          if (redirectTimer) { clearTimeout(redirectTimer); redirectTimer = null; }
          setStatus('lost');
        }
      });
  }
  setInterval(checkConnection, 3000);
  checkConnection();
</script>
</body>
</html>
HTMLEOF

# FIX PERMISSIONS & DOWNLOAD DIRECTORIES
chmod 644 /home/$USERNAME/waiting.html
chmod 644 /home/$USERNAME/fonts/VT323.woff2
chown -R $USERNAME:$USERNAME /home/$USERNAME/fonts /home/$USERNAME/waiting.html

# SETUP OPENBOX SYSTEM MENU
echo "Creating system menu..."
mkdir -p /home/$USERNAME/.config/openbox
cat > /home/$USERNAME/.config/openbox/menu.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="NetClientX">
    <item label="Restart Web Browser">
      <action name="Execute"><command>pkill -f chromium-browser || pkill -f firefox</command></action>
    </item>
    <item label="Open Wi-Fi Settings">
      <action name="Execute"><command>nm-connection-editor</command></action>
    </item>
    <separator />
    <item label="Reboot System">
      <action name="Execute"><command>systemctl reboot</command></action>
    </item>
    <item label="Shutdown System">
      <action name="Execute"><command>systemctl poweroff</command></action>
    </item>
  </menu>
</openbox_menu>
EOF
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
