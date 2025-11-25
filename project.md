---
slug: github-silence-receiver
id: github-silence-receiver
title: AirPlay and Spotify Connect on ThinkPad with ALSA
repo: justin-napolitano/silence_receiver
githubUrl: https://github.com/justin-napolitano/silence_receiver
generatedAt: '2025-11-24T21:36:23.110Z'
source: github-auto
summary: >-
  Set up a minimal shell-based AirPlay and Spotify Connect receiver on ThinkPad laptops using ALSA,
  including a hum silencer script.
tags:
  - alsa
  - shairport-sync
  - librespot
  - bash
  - audio
  - linux
  - thinkpad
seoPrimaryKeyword: thinkpad airplay spotify connect
seoSecondaryKeywords:
  - alsa audio handling
  - hum silencer script
  - shairport-sync setup
  - librespot installation
  - dmix configuration
seoOptimized: true
topicFamily: devtools
topicFamilyConfidence: 0.9
kind: project
entryLayout: project
showInProjects: true
showInNotes: false
showInWriting: false
showInLogs: false
---

A minimal shell-based setup to enable AirPlay and Spotify Connect on ThinkPad laptops using ALSA only, avoiding PulseAudio or PipeWire. Includes a hum silencer script to eliminate idle audio noise.

---

## Features

- AirPlay receiver support via Shairport-Sync
- Spotify Connect support via librespot
- ALSA-only audio handling with system-wide dmix for mixing multiple audio streams
- Hum silencer script to play a silent tone preventing idle hum on Realtek ALC257 codec

## Tech Stack

- Shell scripting (Bash)
- ALSA (Advanced Linux Sound Architecture)
- Shairport-Sync (AirPlay receiver)
- librespot (Spotify Connect client)

## Getting Started

### Prerequisites

- ThinkPad laptop with Realtek ALC257 codec (or similar ALSA-compatible hardware)
- ALSA installed and configured
- Shairport-Sync installed
- librespot installed

### Installation

1. Configure ALSA for system-wide dmix by creating or editing `/etc/asound.conf` with the provided dmix configuration (see below).

2. Place `stop-hum.sh` somewhere accessible (e.g., your home directory or `/usr/local/bin/`).

3. Make sure the silent tone file exists at `~/Music/tones/silence.wav` or update the script path accordingly.

4. Set up Shairport-Sync and librespot to use the ALSA dmix device as output.

### Running

To silence the idle hum after AirPlay disconnects, run the script:

```bash
./stop-hum.sh
```

This script waits 2 seconds, then plays a silent tone to keep ALSA inputs stable.

## Project Structure

```
index.md       # Documentation and setup notes
stop-hum.sh    # Shell script to play silent tone on AirPlay disconnect
```

## ALSA dmix Configuration Example

```conf
# Mix multiple playback clients on Analog (hw:0,0)
pcm.dmixed_analog {
  type dmix
  ipc_key 1024
  ipc_key_add_uid false
  ipc_perm 0666
  slave {
    pcm "hw:0,0"
    rate 44100
    format S16_LE
    channels 2
    period_time 0
    period_size 1024
    buffer_size 8192
  }
}

pcm.!default {
  type plug
  slave.pcm "dmixed_analog"
}

ctl.!default {
  type hw
  card 0
}
```

Adjust `hw:0,0` if your sound card differs.

## Future Work / Roadmap

- Automate hum silencer trigger on AirPlay disconnect events
- Expand support for other hardware codecs
- Integrate librespot and Shairport-Sync service management
- Provide packaged installer or systemd service files
- Add detailed troubleshooting and configuration guides


