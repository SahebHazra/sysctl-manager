# 🧭 Sysman — Systemd Service Manager

[![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=flat&logo=linux&logoColor=black)](https://www.kernel.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](LICENSE)

**Sysman** is a lightweight, modular, and interactive command-line utility for managing `systemd` services on Linux. Built with Bash, it provides a straightforward terminal interface for inspecting service states, starting and stopping services, and tracking changes made through the tool.

Designed for Linux enthusiasts, system administrators, and DevOps learners, Sysman simplifies common service-management tasks without the overhead of a graphical interface.

## 📑 Table of Contents

- [✨ Features](#-features)
- [📂 Project Structure](#-project-structure)
- [⚙️ Requirements](#️-requirements)
- [🚀 Installation](#-installation)
- [💻 Usage](#-usage)
- [🔍 How It Works](#-how-it-works)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)

## ✨ Features

- **🟢 Active Services** — Inspect running and activating services and selectively stop services when needed.
- **📜 Action History** — Track services stopped through Sysman and review the recorded history.
- **🔄 Service Recovery** — Quickly identify previously stopped services and restart them when required.
- **📋 Inactive Service Management** — Browse inactive, failed, dead, static, and masked service states through categorized views.
- **🔢 Quick Selection** — Use intuitive alphanumeric identifiers, such as `a1` or `d3`, to select services from interactive lists.
- **🛡️ Environment Validation** — Check for the required Bash version and a compatible `systemd` environment before execution.
- **🧩 Modular Architecture** — Keep the entry point, configuration, and service-management logic separated for easier maintenance.
- **⚡ Lightweight & Terminal-Based** — Runs with Bash and standard Linux system utilities, without requiring a graphical interface.

## 📂 Project Structure

Sysman uses a modular directory layout to separate application entry-point logic, configuration, and service-management functionality.

```text
sysctl-manager/
├── bin/
│   └── sysman          # Main executable and interactive menu
├── lib/
│   ├── config.sh       # Configuration and state initialization
│   └── services.sh     # Service discovery and management logic
├── .gitignore
├── LICENSE
└── README.md
```

## ⚙️ Requirements

Before installing Sysman, ensure your system has:

- **Operating system:** Linux distribution using `systemd`, such as Ubuntu, Debian, Fedora, Arch Linux, or RHEL.
- **Bash:** Version 4.0 or later.
- **systemd:** Required for service discovery and management.
- **Privileges:** Appropriate permissions to start or stop system-level services. `sudo` may be required, depending on the service and system configuration.

## 🚀 Installation

### 1. Clone the repository

```bash
git clone https://github.com/SahebHazra/sysctl-manager.git
cd sysctl-manager
```

### 2. Make the executable runnable

```bash
chmod +x bin/sysman
```

### 3. Launch Sysman

```bash
./bin/sysman
```

Follow the interactive menu to inspect and manage services.

> **Note:** Run Sysman with the permissions required for the operations you intend to perform. Avoid running the entire application as root unless necessary.

## 💻 Usage

Start the application from the cloned repository:

```bash
./bin/sysman
```

Use the interactive interface to browse available service categories, select services using their displayed identifiers, and perform the supported actions.

Sysman also records services stopped through the tool, making it easier to review previous actions and identify services you may want to restart.

## 🔍 How It Works

### State Tracking

Sysman maintains a local record of services stopped through the application:

```text
~/.stopped_by_script.txt
```

This record helps you identify services affected by previous operations. It is a tracking mechanism, not a replacement for `systemd`'s actual service state.

### Dynamic Path Resolution

The main executable resolves its own location dynamically, allowing it to locate and source the required library files without relying on the current working directory.

### Modular Design

The codebase separates responsibilities across three main components:

- **`bin/sysman`** — Application entry point and interactive menu.
- **`lib/config.sh`** — Configuration variables and state initialization.
- **`lib/services.sh`** — Service discovery, state handling, and management operations.

This structure makes the project easier to understand, maintain, and extend.

## 🤝 Contributing

Contributions, bug reports, suggestions, and feature requests are welcome!

To contribute:

1. Fork this repository.
2. Create a feature branch:

   ```bash
   git checkout -b feature/your-feature
   ```

3. Implement and test your changes.
4. Commit your work:

   ```bash
   git add .
   git commit -m "feat: describe your change"
   ```

5. Push your branch:

   ```bash
   git push origin feature/your-feature
   ```

6. Open a pull request describing your changes.

For larger changes, consider opening an issue first to discuss the proposed implementation.

## 📜 License

Sysman is distributed under the [MIT License](LICENSE).

You are free to use, modify, and distribute this software in accordance with the terms of the license.
