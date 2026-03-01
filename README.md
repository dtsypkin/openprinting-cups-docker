# CUPS Docker Auto-Builder 🖨️

A fully automated, multi-architecture Docker setup for the [Common UNIX Printing System (CUPS)](https://github.com/OpenPrinting/cups). 

This repository doesn't just host a `Dockerfile`. It uses a "smart polling" GitHub Actions workflow to check for new stable releases from the official OpenPrinting repository and automatically builds a fresh Docker image whenever a new version is out.

## ✨ Features

* **Always Up-to-Date:** The GitHub Actions workflow checks for new upstream releases every 3 hours. If a new version is detected, it builds and pushes a new image automatically.
* **Multi-Architecture:** Built for both `linux/amd64` (standard PCs/servers) and `linux/arm64` (perfect for ARM-based boards like Raspberry Pi).
* **Portainer & Watchtower Ready:** Designed to be easily deployed via Docker Compose and seamlessly updated in the background using Watchtower.
* **Pre-configured Web UI Access:** Comes with a default admin user and pre-configured network settings to allow remote access to the CUPS Web Interface right out of the box.

## 🚀 Quick Start (Docker Compose)

To deploy this container, you can use the following `docker-compose.yml` file. It is optimized for environments like Portainer.

```yaml
version: '3.8'

services:
  cups:
    image: ghcr.io/dtsypkin/openprinting-cups-docker:latest
    container_name: cups-server
    restart: unless-stopped
    ports:
      - "631:631"
    volumes:
      # Stores printer configurations and system settings
      - cups_config:/etc/cups
      
      # Stores the print queue and cache
      # Recommendation: Bind mount to a fast external SSD if available
      - cups_spool:/var/spool/cups
      
    devices:
      # Crucial for USB printer passthrough
      - /dev/bus/usb:/dev/bus/usb
      
    labels:
      # Explicitly enable Watchtower automatic updates for this container
      - "com.centurylinklabs.watchtower.enable=true"

volumes:
  cups_config:
  cups_spool:
```
## ⚙️ Configuration & Access

Once the container is up and running, open your web browser and navigate to:

👉 **`http://<your-server-ip>:631`**

To add printers or modify administrative settings via the Web UI, use the following default credentials:

* **Username:** `admin`
* **Password:** `admin`

## 🔌 Connecting Physical USB Printers

If you are using a physical printer connected via a USB cable, ensure the printer is turned on and plugged into the host machine *before* starting the container. The `devices: - /dev/bus/usb:/dev/bus/usb` directive in the Compose file passes the host's USB bus directly into the container so CUPS can detect the hardware.

## 🔄 How the Automation Works

1. A scheduled cron job in GitHub Actions runs every 3 hours.
2. It queries the GitHub API for the latest release tag of `OpenPrinting/cups`.
3. It checks this GitHub Container Registry (GHCR) to see if an image with this tag already exists.
4. If the tag is new, it triggers a multi-architecture `buildx` process using QEMU, compiling the CUPS source code from scratch.
5. The new image is pushed to GHCR, updating the `latest` tag.
6. If you have Watchtower running in your home lab, it will detect the updated `latest` tag and seamlessly recreate your local container.
