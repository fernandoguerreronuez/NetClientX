<div align="center">

# 🌐 NetClientX

**Give your old PC a second life.**

[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Ubuntu%20Server-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Browser](https://img.shields.io/badge/Browser-Chromium%20%7C%20Firefox-orange)](https://www.chromium.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

</div>

---

## What is NetClientX?

NetClientX is a bash script that turns any old laptop or PC into a lightweight thin client. It installs a minimal graphical environment with a web browser, Wi-Fi support, and automatic updates — no desktop environment needed.

Perfect for breathing new life into old hardware and using it to connect to remote desktops via Google Remote Desktop, TeamViewer, AnyDesk, or any other web-based remote access tool.

---

## Features

- **Minimal footprint** — only installs what's strictly necessary
- **Wi-Fi support** — includes a system tray icon to connect to any Wi-Fi network
- **Always up to date** — runs `apt update && apt upgrade` automatically on every boot
- **Connection screen** — displays a waiting screen on boot that redirects to your portal once internet is available
- **Compatible with Chromium and Firefox** — choose the browser that works best for your hardware
- **Works on low-resource systems** — designed and tested on hardware with limited CPU and RAM

---

## Resource usage (idle)

Tested on a system with Ubuntu Server 26.04 + NetClientX fully running, with no active remote desktop connections:

| Resource | Value |
|---|---|
| CPU usage | ~0.5% |
| RAM used by processes | ~1.1 GB |
| RAM available | ~2.2 GB |
| Total RAM | ~3.3 GB |

With no active sessions, the system leaves over 2 GB of RAM available. During an active remote desktop session, browser and connection overhead will consume additional memory, but the system is designed to handle this comfortably on machines with 3-4 GB of RAM.

---

## How does it work?

1. Install **Ubuntu Server** on your old PC or laptop
2. Download and run the NetClientX script
3. Enter your portal URL when prompted
4. The system reboots and opens the browser automatically — ready to use

On boot, a custom waiting screen is shown. Once internet is detected, it redirects automatically to your configured URL.

---

## What does it install?

- **Xorg** — minimal display server
- **Openbox** — ultra-lightweight window manager
- **Chromium** or **Firefox** — web browser in fullscreen
- **NetworkManager + nm-applet** — Wi-Fi management from a system tray icon
- **tint2** — minimal taskbar to display the Wi-Fi icon

---

## Requirements

- Ubuntu Server 26.04 LTS (or later)
- Internet connection (Ethernet recommended for the initial setup)
- Any x86-64 PC or laptop — the older the better

---

## Installation & usage

1. Install Ubuntu Server on your machine
2. Clone this repository or download the script:
   ```bash
   git clone https://github.com/fernandoguerreronuez/netclientx.git
   cd netclientx
   ```
3. Give execution permissions and run:
   ```bash
   # Chromium version
   chmod +x netclientx-chromium.sh
   sudo ./netclientx-chromium.sh

   # Firefox version
   chmod +x netclientx-firefox.sh
   sudo ./netclientx-firefox.sh
   ```
4. Enter your portal URL when prompted
5. The system will install everything and reboot automatically
6. After reboot, the browser will open in fullscreen — done!

> ⚠️ **Note:** Run the script as your regular user with `sudo`, not as root directly, so the autologin and autostart are configured for the correct user.

---

## Wi-Fi

After the first boot, press **F11** to exit fullscreen, then click the network icon in the taskbar, select your Wi-Fi network and enter the password. The connection will be remembered for future reboots. Press **F11** again to return to fullscreen.

---

## Auto-updates

NetClientX configures a systemd service that runs `apt update && apt upgrade` automatically on every boot, keeping the system up to date without any manual intervention.

---

## Available scripts

| Script | Browser |
|---|---|
| `netclientx-chromium.sh` | Chromium |
| `netclientx-firefox.sh` | Firefox |

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Credits

Created by **Fernando Guerrero Nuez** — Systems Administrator

🌐 [fernandoguerreronuez.com](https://fernandoguerreronuez.com/)
