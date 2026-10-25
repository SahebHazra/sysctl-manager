# 🧭 Sysman — Systemd Service Manager

[![Language: Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=flat&logo=linux&logoColor=black)](https://www.kernel.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](LICENSE)

**Sysman** is a lightweight, interactive command-line utility for inspecting and managing `systemd` services on Linux. It can list service states, stop and start services, and keep a local history of services stopped through the tool.

## Features

- **Active services:** Browse active and activating services and select one to stop.
- **Action history:** Track services stopped through Sysman and restart them from the history list.
- **Non-active services:** Browse loaded services grouped by failed, inactive/dead, and other non-active states.
- **Quick selection:** Use numbered entries or category codes such as `a1` and `d2`.
- **Modular Bash code:** Keep the executable, configuration, and service operations in separate files.
- **Lightweight:** Uses Bash and standard Linux command-line utilities; no graphical interface required.

## Project structure

```text
sysctl-manager/
├── bin/
│   └── sysman
├── lib/
│   ├── config.sh
│   └── services.sh
├── LICENSE
└── README.md
```

## Requirements

- Linux with `systemd`
- Bash 4.0 or later
- `systemctl`, `awk`, `grep`, `mktemp`, and standard shell utilities
- `sudo` privileges for whichever service actions require them

## Installation

```bash
git clone https://github.com/SahebHazra/sysctl-manager.git
cd sysctl-manager
chmod +x bin/sysman
./bin/sysman
```

Run Sysman as your normal user and allow `sudo` only for individual service operations when needed. Stopping or starting system services can affect your system; avoid changing services unless you understand their purpose.

## Usage

Choose an option from the menu:

1. **Active Services:** view active/activating services and stop a selected service.
2. **Services stopped by this script:** inspect the local history and restart a selected service.
3. **Inactive/Other Services:** view non-active loaded services and start a selected service.
4. **909:** exit.

The history is stored at:

```text
~/.stopped_by_script.txt
```

This is only Sysman's own action history, not a complete record of all service changes on the system. Starting a service from the history removes it from the history after the start command succeeds.

## Development checks

Run syntax checks from the repository root:

```bash
bash -n bin/sysman lib/config.sh lib/services.sh
```

If ShellCheck is installed, also run:

```bash
shellcheck bin/sysman lib/config.sh lib/services.sh
```

## Contributing

Bug reports, suggestions, and pull requests are welcome. Please run the checks above before submitting a change.

## License

Sysman is distributed under the [MIT License](LICENSE).
