<div align="center">

# 🌐 NetClientX

**Give your old PC a second life.**

[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Ubuntu%20Server-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Browser](https://img.shields.io/badge/Browser-Chromium-4285F4?logo=googlechrome&logoColor=white)](https://www.chromium.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

</div>

---

## What is NetClientX?

NetClientX is a bash script that turns any old laptop or PC into a lightweight thin client. It installs a minimal graphical environment with Chromium in fullscreen, Wi-Fi support, and automatic updates — no desktop environment needed.

Perfect for breathing new life into old hardware and using it to connect to remote desktops via Google Remote Desktop, TeamViewer, AnyDesk, or any other web-based remote access tool.

---

## Features

- **Minimal footprint** — only installs what's strictly necessary
- **Hardened by default** — disables unnecessary services (SSH, Bluetooth, CUPS, Avahi, snapd and others) on installation
- **Wi-Fi support** — system tray icon to connect to any Wi-Fi network, plus a right-click menu for quick access
- **Always up to date** — runs `apt dist-upgrade` automatically on every boot, at low CPU and I/O priority so it never interferes with the session
- **Connection screen** — displays a waiting screen on boot that redirects to your portal once internet is available. If the connection drops, the waiting screen reappears automatically
- **Works on low-resource systems** — designed and tested on hardware with limited CPU and RAM

---

## Resource usage (idle)

Tested on Ubuntu Server 24.04 + NetClientX fully running, with no active remote desktop connections:

| Resource | Value |
|---|---|
| CPU usage | ~0.5% |
| RAM used by processes | ~1.1 GB |
| RAM available | ~2.2 GB |
| Total RAM | ~3.3 GB |

With no active sessions, the system leaves over 2 GB of RAM available. During an active remote desktop session, browser and connection overhead will consume additional memory, but the system is designed to handle this comfortably on machines with 3–4 GB of RAM.

---

## How does it work?

1. Install **Ubuntu Server** on your old PC or laptop
2. Download and run the NetClientX script
3. Enter your portal URL when prompted
4. The system reboots and opens Chromium automatically — ready to use

On boot, a custom waiting screen is shown. Once internet is detected, it redirects automatically to your configured URL. If the connection drops at any point, the waiting screen reappears automatically.

---

## What does it install?

- **Xorg** — minimal display server
- **Openbox** — ultra-lightweight window manager with a right-click system menu
- **Chromium** — web browser in fullscreen mode
- **NetworkManager + nm-applet** — Wi-Fi management from a system tray icon
- **tint2** — minimal taskbar to display the Wi-Fi tray icon
- **wget** — used to download the local font during setup
- **polkitd / pkexec** — allows the regular user to reboot and shut down from the right-click menu

---

## What does it disable?

On installation, the following services are stopped and disabled to reduce the attack surface and resource usage:

| Service | Reason |
|---|---|
| `ssh` | Not needed on a thin client; re-enable manually if required |
| `snapd` | No snaps are used |
| `multipathd` | SAN multipath, irrelevant on standard hardware |
| `ModemManager` | 3G/4G modem support, not needed |
| `cups` / `cups-browsed` | Printing, not needed |
| `avahi-daemon` | mDNS/Zeroconf, not needed on managed networks |
| `apport` | Crash reporting, not needed in production |
| `unattended-upgrades` | Replaced by the NetClientX auto-update service |
| `bluetooth` | Not needed; re-enable manually if required |

---

## Requirements

- Ubuntu Server 24.04 LTS (or later)
- Internet connection (Ethernet recommended for the initial setup)
- Any x86-64 PC or laptop — the older the better

---

## Installation & usage

1. Install Ubuntu Server on your machine
2. Clone this repository or download the script:
   ```bash
   git clone https://github.com/fernandoguerreronuez/NetClientX.git
   cd NetClientX
   ```
3. Give execution permissions and run:
   ```bash
   chmod +x netclientx-chromium.sh
   sudo ./netclientx-chromium.sh
   ```
4. Enter your portal URL when prompted (e.g. `https://remotedesktop.google.com`)
5. The script will install everything, configure the system and reboot automatically
6. After reboot, Chromium will open in fullscreen — done!

> ⚠️ **Note:** Always run the script with `sudo` as your regular user, not as root directly. This ensures autologin and autostart are configured for the correct user account.

---

## Wi-Fi

After the first boot, **right-click** anywhere on the desktop to open the system menu and select **Open Wi-Fi Settings**. Select your network, enter the password, and the connection will be remembered for future reboots.

The right-click menu also gives you quick access to:

- **Restart Web Browser** — kills and restarts Chromium without rebooting
- **Reboot System**
- **Shutdown System**

---

## Auto-updates

NetClientX configures a systemd service (`netclientx-update.service`) that runs `apt dist-upgrade` automatically on every boot. The service runs at the lowest CPU and I/O priority (`Nice=19`, `IOSchedulingClass=idle`) and is fully non-interactive, so it never blocks the session or prompts for input.

This service replaces `unattended-upgrades`, which is disabled during installation.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Credits

Created by **Fernando Guerrero Nuez** — Systems Administrator

🌐 [fernandoguerreronuez.com](https://fernandoguerreronuez.com/)
