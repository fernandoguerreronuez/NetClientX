#!/bin/bash
# NetClientX V1
# UPDATE AND INSTALL SOFTWARE
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt install -y --no-install-recommends xorg openbox firefox network-manager network-manager-gnome tint2
# GET USERNAME
USERNAME=$(logname)
# GET CONNECTION URL
read -p "Enter connection URL: " URL
# GENERATE WAITING PAGE
cat > /home/$USERNAME/waiting.html << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>NetClientX</title>
  <link href="https://fonts.googleapis.com/css2?family=VT323&display=swap" rel="stylesheet" />
  <style>
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
# FIX WAITING PAGE PERMISSIONS
chmod 644 /home/$USERNAME/waiting.html
chown $USERNAME:$USERNAME /home/$USERNAME/waiting.html
# SETUP AUTOLOGIN
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
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
# OPENBOX, FIREFOX, TINT2 AND NM-APPLET AUTOSTART
cat > /home/$USERNAME/.xinitrc <<EOF
openbox &
tint2 &
nm-applet &
python3 -m http.server 8080 --bind 127.0.0.1 --directory /home/$USERNAME &
sleep 1
while true; do
    firefox --kiosk http://localhost:8080/waiting.html
    sleep 2
done
EOF
# APPLY CHANGES
sudo systemctl daemon-reload
# AUTO UPDATE ON BOOT
sudo tee /etc/systemd/system/autoupdate.service <<EOF
[Unit]
Description=Auto update on boot
After=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=/usr/bin/apt update
ExecStart=/usr/bin/apt upgrade -y
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable autoupdate.service
sudo apt autoremove -y
# REBOOT
sudo reboot
