+++
title = "Airplay and Spotify with Signal Cancel (ThinkPad ALC257)"
date = "2025-10-21T15:31:48-05:00"
description = "Setting up Shairport-Sync, Librespot, and a hum silencer using ALSA only on ThinkPad hardware with Realtek ALC257."
author = "Justin Napolitano"
categories = ["projects", "audio", "linux"]
tags = ["alsa", "airplay", "spotify", "thinkpad", "shairport-sync", "librespot"]
[extra]
lang = "en"
toc = true
featured = false
reaction = false
+++

# How I got AirPlay (and Spotify Connect) working on a ThinkPad with **ALSA only**—and killed the idle hum

PulseAudio/pipewire wasn’t cooperating on my ThinkPad (Realtek **ALC257**). I wanted **Shairport-Sync** (AirPlay) and **librespot** (Spotify Connect) to play directly through **ALSA**, _mix_ with each other, and **not** buzz when idle. Here’s the exact setup that finally worked.

---

## Hardware & goal

- **Laptop**: ThinkPad T-series  
- **Codec**: Realtek **ALC257**  
- **ALSA only** (no PulseAudio/pipewire)  
- Services:  
  - **Shairport-Sync** (AirPlay receiver)  
  - **librespot** (Spotify Connect)  
  - **Hum silencer** keep-alive so inputs don’t float (no buzz when idle)

---

## 1) Create a shared output with **dmix** (system-wide)

ALSA doesn’t mix by default. `dmix` lets multiple apps share the same device. Put this in **`/etc/asound.conf`**:

```conf
# Mix multiple playback clients on Analog (hw:0,0)
pcm.dmixed_analog {
  type dmix
  ipc_key 1024
  ipc_key_add_uid false   # allow all users/services to share the same segment
  ipc_perm 0666           # read/write for everyone
  slave {
    pcm "hw:0,0"          # ALC257 Analog; verify with `aplay -l`
    rate 44100            # or 48000 if your card prefers it
    format S16_LE
    channels 2
    period_time 0
    period_size 1024
    buffer_size 8192
  }
}

# Route default through dmix (with automatic format conversion)
pcm.!default {
  type plug
  slave.pcm "dmixed_analog"
}

ctl.!default {
  type hw
  card 0
}
```

> If your card is not `hw:0,0`, change both the `pcm "hw:X,Y"` and `card` lines accordingly (`aplay -l` shows the indexes).  
> If you switch to 48 kHz later, update **all** commands/services to match that rate.

---

## 2) Add a **hum silencer** keep-alive (systemd, ALSA only)

Many receivers hum when the source goes idle (the DAC output “floats”). We keep the device **lightly busy** with a near-zero signal so the analog stage stays biased.

A robust service is a SoX→aplay pipe (SoX generates, aplay talks to ALSA):

**`/etc/systemd/system/alsa-keepalive.service`**
```ini
[Unit]
Description=Keep ALSA output active to prevent hum (sox->aplay)
After=sound.target
Wants=sound.target
StartLimitIntervalSec=0

[Service]
ExecStart=/bin/bash -lc '/usr/bin/sox -q -r 44100 -c 2 -b 16 -e signed-integer -n -t raw - synth 0 pinknoise vol 0.0006 | /usr/bin/aplay -q -D default -f S16_LE -c 2 -r 44100'
Restart=always
RestartSec=2
Nice=10

[Install]
WantedBy=multi-user.target
```

Enable it:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now alsa-keepalive.service
```

_Alternative_: if you prefer a sub-bass tone that’s usually inaudible:
```bash
... synth 0 sine 40 vol 0.001 | aplay ...
```

---

## 3) Configure **Shairport-Sync** to use `default` (dmix), not `hw:0,0`

Depending on how you installed it, your config is either `/etc/shairport-sync.conf` or `/usr/local/etc/shairport-sync.conf`. Mine was `/usr/local/etc/shairport-sync.conf`.

**Minimal working config**:

```conf
general = {
  name = "Tulip Speaker";
  mdns_backend = "avahi";
  log_verbosity = 2;
  output_backend = "alsa";
};

alsa = {
  output_device = "default";       # use dmix, not hw
  use_mmap = "no";                 # safer on some Intel HDA
  output_format = "S16";
  output_rate = 44100;             # match /etc/asound.conf
  mixer_control_name = "Headphone";# pick a control that exists on your card
  mixer_device = "hw:0";
};
```

Restart and verify logs reference **`default`** (not `plughw:0,0`):
```bash
sudo systemctl restart shairport-sync
sudo journalctl -u shairport-sync -b | grep -E 'output device name|PCM handle name'
```

---

## 4) Configure **librespot** (Spotify Connect) for ALSA + hardware mixer

**`/etc/systemd/system/librespot.service`**
```ini
[Unit]
Description=Spotify Connect (librespot)
After=network-online.target sound.target
Wants=network-online.target

[Service]
User=spotify
Group=audio
WorkingDirectory=/var/lib/librespot

ExecStart=/usr/local/bin/librespot   -n "Jaybird's Jam"   -B alsa   -d default   -m alsa   -S hw:0   -T "Headphone"   -b 160   -G   -C /var/lib/librespot   -z 8765   -i 192.168.1.115   -v

Restart=always
RestartSec=5
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

---

## 5) Verify

- `aplay -D default -f S16_LE -r 44100 /usr/share/sounds/alsa/Front_Center.wav` plays.  
- `systemctl status alsa-keepalive` → running (no hum when idle).  
- AirPlay + Spotify play together without “device busy”.  
- Mixer control (`Headphone`) adjusts volume correctly.

---

### Final note

This configuration keeps the setup **pure ALSA**—no PulseAudio, no PipeWire.  
Everything shares the same `default` dmix sink, stays silent when idle, and your ThinkPad’s analog output finally behaves like proper audio gear.
