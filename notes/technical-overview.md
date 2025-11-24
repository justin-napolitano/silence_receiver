---
slug: github-silence-receiver-note-technical-overview
id: github-silence-receiver-note-technical-overview
title: silence_receiver
repo: justin-napolitano/silence_receiver
githubUrl: https://github.com/justin-napolitano/silence_receiver
generatedAt: '2025-11-24T18:46:38.382Z'
source: github-auto
summary: >-
  This repo is a minimal setup for running AirPlay and Spotify Connect on
  ThinkPads using ALSA, ditching PulseAudio and PipeWire. It includes a hum
  silencer script that eliminates idle audio noise.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: note
entryLayout: note
showInProjects: false
showInNotes: true
showInWriting: false
showInLogs: false
---

This repo is a minimal setup for running AirPlay and Spotify Connect on ThinkPads using ALSA, ditching PulseAudio and PipeWire. It includes a hum silencer script that eliminates idle audio noise.

## Key Components

- **Shairport-Sync**: For AirPlay support.
- **librespot**: For Spotify Connect.
- **Bash scripts**: Handles configuration and noise reduction.

## Quick Start

1. Ensure your ThinkPad has ALSA configured and install Shairport-Sync and librespot.
2. Set up ALSA's dmix in `/etc/asound.conf`:
   ```conf
   pcm.!default {
     type plug
     slave.pcm "dmixed_analog"
   }
   ```
3. Add `stop-hum.sh` to your path and make sure `~/Music/tones/silence.wav` exists.
4. Run the hum silencer with:
   ```bash
   ./stop-hum.sh
   ```

**Gotcha**: Make sure to adjust `hw:0,0` in the ALSA config if your sound card differs.
