# 🔤 Nerd Fonts Auto-Installer

A lightweight, automated Bash script designed to fetch, extract, and install specific font families from the official [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) repository. 

The script dynamically queries the GitHub API to ensure it always downloads the latest available release (v3+). It installs the fonts safely at the user level (`~/.local/share/fonts`) and automatically updates the system font cache.

## 🚀 Included Fonts
By default, the script deploys the following icon-patched font families:
* **Hack**
* **Gohu**
* **Iosevka**
* **IosevkaTerm**
* **Anonymous Pro**

## 🛠️ Prerequisites

The script will check for required tools before executing. On Debian-based distributions (like Debian, Ubuntu, or Kali Linux), you can install any missing dependencies with:

```bash
sudo apt update
sudo apt install curl unzip fontconfig jq
