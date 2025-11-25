---
slug: github-silence-receiver
title: AirPlay and Spotify Connect on ThinkPad with ALSA
repo: justin-napolitano/silence_receiver
githubUrl: https://github.com/justin-napolitano/silence_receiver
generatedAt: '2025-11-23T09:38:25.966396Z'
source: github-auto
summary: >-
  This guide details configuring ALSA for AirPlay and Spotify Connect on
  ThinkPads, addressing audio mixing and idle hum issues.
tags:
  - alsa
  - thinkpad
  - airplay
  - spotify-connect
  - linux-audio
  - dmix
  - shairport-sync
  - librespot
  - audio streaming
  - linux
seoPrimaryKeyword: alsa airplay spotify connect thinkpad
seoSecondaryKeywords:
  - realtek alc257 codec
  - linux audio configuration
  - hum silencer script
  - audio mixing
  - shairport-sync configuration
seoOptimized: true
topicFamily: devtools
topicFamilyConfidence: 0.95
topicFamilyNotes: >-
  The post is focused on configuring and troubleshooting a Linux audio
  environment on a ThinkPad, specifically ALSA setup and custom scripts for
  audio hum suppression — a topic closely aligned with development environment
  configuration and tooling. It covers shell scripting, hardware configuration,
  and Linux system details, fitting the 'Devtools' category best.
kind: project
id: github-silence-receiver
---

# AirPlay and Spotify Connect on ThinkPad with ALSA Only: A Technical Reference

This project addresses the challenge of running AirPlay and Spotify Connect audio streaming on a ThinkPad laptop using ALSA exclusively, without relying on PulseAudio or PipeWire. The motivation stems from compatibility issues and audio quality concerns with PulseAudio/pipewire on certain hardware, specifically the Realtek ALC257 codec found in ThinkPad T-series laptops.

## Problem Statement

PulseAudio and PipeWire, while common in Linux audio stacks, sometimes introduce latency, instability, or hardware compatibility problems. The Realtek ALC257 codec on ThinkPads has exhibited such issues, making it difficult to run Shairport-Sync (AirPlay receiver) and librespot (Spotify Connect client) reliably.

Additionally, ALSA by itself does not natively mix multiple audio streams, which is required to have both AirPlay and Spotify Connect outputs playing simultaneously. Another common problem is an audible idle hum when no audio is playing, caused by floating inputs in the codec.

## Solution Overview

The approach uses ALSA's `dmix` plugin to create a system-wide shared output device that mixes audio streams from multiple clients. This allows Shairport-Sync and librespot to output through the same ALSA device concurrently.

To eliminate the idle hum, a small shell script plays a silent audio tone after AirPlay disconnects, keeping the audio input active and preventing floating signals.

## Implementation Details

### ALSA Configuration

The core of the solution is the `/etc/asound.conf` file defining a `dmixed_analog` PCM device:

- Uses `dmix` type with IPC keys and permissions set to allow all users and services to access the shared segment.
- Targets the hardware device `hw:0,0` representing the analog output of the Realtek ALC257.
- Sets parameters such as sample rate (44100 Hz), format (S16_LE), channels (2), and buffer sizes optimized for low latency and stability.
- Overrides the default PCM to route through this dmix device, enabling seamless mixing.

### Hum Silencer Script

The `stop-hum.sh` script is a simple Bash script that:

- Waits 2 seconds (to allow any disconnect events to settle).
- Plays a silent WAV file (`silence.wav`) located in the user's Music directory using `aplay` in quiet mode.

This keeps the codec inputs active and prevents the characteristic idle hum.

### Integration

Shairport-Sync and librespot are configured to output to the ALSA default device, which is now the dmix-enabled device. The hum silencer script can be triggered manually or integrated into disconnect event hooks.

## Practical Considerations

- The ALSA device name `hw:0,0` may vary; users should verify with `aplay -l`.
- The silent tone file must be a valid WAV file of silence; creating or sourcing this file is necessary.
- This setup assumes a Linux environment with ALSA and the relevant audio clients installed.

## Summary

This project provides a practical, low-level audio configuration for Linux users on ThinkPads with Realtek ALC257 codecs who require stable AirPlay and Spotify Connect streaming without the overhead or issues of PulseAudio or PipeWire. It leverages ALSA's dmix for mixing and a simple shell script to suppress idle hum, enabling a clean and reliable audio experience.

The documentation and scripts serve as a reference for future maintenance or adaptation to similar hardware and use cases.

