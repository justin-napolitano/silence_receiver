+++
title = "Ubuntu → Spotify Connect speaker (ALSA-only, headless)"
date = "2025-10-17"
description = "Librespot with ALSA backend, no PipeWire. Headless OAuth via SSH tunnel."
author = "Justin Napolitano"
taxonomies.categories = ["projects"]
taxonomies.tags = ["linux","ubuntu","spotify","librespot","alsa","headless","zola"]
[extra]
toc = true
featured = false
+++

## Goal
Turn an Ubuntu box into a Spotify Connect target named **Apartment Jam** using ALSA only.

## What this does
- Builds `librespot` with `alsa-backend` and `libmdns`
- Pins audio to `plughw:0,0`
- Runs as system user `spotify`
- Advertises over mDNS and opens firewall
- Persists creds under `/var/lib/librespot`

## Install
```bash
# download and run the installer
curl -fsSL https://example.com/librespot_alsa_install.sh -o /tmp/librespot_alsa_install.sh
sudo bash /tmp/librespot_alsa_install.sh
```

## One-time OAuth on a headless box
On the server:
```bash
sudo -u spotify /usr/local/bin/librespot \
  -n "Apartment Jam" -B alsa -d plughw:0,0 -b 160 -R 75 -E log \
  -i $(hostname -I | awk '{print $1}') -z 8765 -C /var/lib/librespot -K 8888 -j
```
Leave that running. From your laptop:
```bash
ssh -L 8888:127.0.0.1:8888 cobra@SERVER_LAN_IP
# open the printed Spotify URL, finish login, wait for "Logged in"
```
Then:
```bash
sudo systemctl restart librespot
```

## Connect from phone
Same Wi-Fi → play a track → device icon → **Apartment Jam**.

## Quick ops
```bash
journalctl -u librespot -f
sudo systemctl restart librespot
avahi-browse -rt _spotify-connect._tcp | grep "Apartment Jam"
```

## Notes
- If the device never appears, disable AP “client isolation” and allow UDP 5353.
- To update:
```bash
cargo install librespot --locked --no-default-features --features "alsa-backend native-tls with-libmdns"
sudo install -m0755 ~/.cargo/bin/librespot /usr/local/bin/librespot
sudo systemctl restart librespot
```
