# 🧭 Sysman (Systemd Service Manager)

[![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=flat&logo=linux&logoColor=black)](https://www.kernel.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A lightweight, modular, and interactive CLI tool written in Bash to manage, monitor, and troubleshoot `systemd` services efficiently.
Designed for Linux system administrators and DevOps engineers who want a quick, clean terminal interface without leaving the command line.


## 📂 Project Architecture

Unlike traditional single-script tools, **sysman** is engineered with a modular directory structure, separating configuration, core business logic, and the execution entry point:

```text
sysctl-manager/
├── bin/
│   └── sysman          # Main entry point & interactive menu loop
├── lib/
│   ├── config.sh       # Global variables and state initialization
│   └── services.sh     # Core systemctl parsing and management logic
├── .gitignore
├── LICENSE
└── README.md


## ✨ Features
    🟢 Active & Activating Services: View running services in real-time and selectively stop them. Automatically tracks actions in a local state file for safety.
    ⚙️ Script History Log: Easily inspect and restart services that were previously stopped by this script.
    📋 Inactive & Grouped Services: Intelligently categorizes inactive-related services (failed, inactive, dead, static/masked) and allows quick start execution using intuitive alphanumeric codes (e.g., a1, d3).
    🛡️ Environment Validation: Gracefully checks for systemd and bash compatibility at startup.


## 🚀 Getting Started
Prerequisites

    A Linux distribution utilizing systemd (Ubuntu, CentOS, RHEL, Fedora, Arch, etc.)
    Bash v4.0+ (required for mapfile array support)
    sudo privileges (needed to start/stop system-level services)

Installation & Usage

  1  Clone the repository:
    '''bash
    git clone https://github.com/saheb_hazra/sysctl-manager.git
    cd sysctl-manager

  2  Make the binary executable:
    '''bash
    chmod +x bin/sysman

  3  Run the tool:
    '''bash
    ./bin/sysman



## 🛠️ How It Works

    State Tracking: To ensure you don't lose track of what you've shut down, stopped services are logged locally at ~/.stopped_by_script.txt.
    Dynamic Path Resolution: The entry point uses dynamic dirname evaluation so that the application can be called from any directory path without breaking library sourcing.




## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

    Fork the Project
    Create your Feature Branch (git checkout -b feature/AmazingFeature)
    Commit your Changes (git commit -m 'feat: add some AmazingFeature')
    Push to the Branch (git origin push feature/AmazingFeature)
    Open a Pull Request



## 📝 License

Distributed under the MIT License. See LICENSE for more information.






