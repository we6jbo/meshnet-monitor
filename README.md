# Meshnet Monitor

A lightweight Bash script that:

- Checks for Meshnet connectivity to a Raspberry Pi
- Automatically opens an SSH session if reachable
- Logs and notifies high system load or memory usage
- Optionally runs a fallback fix script from `/tmp`

## Requirements

- `libnotify-bin` (for desktop notifications)
- `gnome-terminal` (or change to your terminal of choice)
- Tested on Debian-based systems (Lenovo T14 w/ GNOME)

## Installation

```bash
mkdir -p ~/.local/bin
cp meshnet-monitor.sh ~/.local/bin/
chmod +x ~/.local/bin/meshnet-monitor.sh

