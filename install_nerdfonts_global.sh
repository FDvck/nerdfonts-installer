#!/bin/bash

# 1. Check if the script is running as root (required for system-wide installation)
if [ "$EUID" -ne 0 ]; then
    echo "[!] Error: Please run this script with sudo or as root."
    echo "    Example: sudo ./install_nerdfonts.sh"
    exit 1
fi

# System-wide fonts directory
FONT_DIR="/usr/local/share/fonts/NerdFonts"

# Explicit array of exact .zip file names in the repository
FONTS=("Hack" "Gohu" "Iosevka" "IosevkaTerm" "AnonymousPro")

# 2. Check for required dependencies
for cmd in curl unzip fc-cache jq; do
    if ! command -v $cmd &> /dev/null; then
        echo "[!] Error: the command '$cmd' is not installed."
        echo "    Install it using: apt install $cmd"
        exit 1
    fi
done

# 3. Dynamically fetch the latest release tag from GitHub API
echo "[+] Fetching the latest Nerd Fonts release tag..."
VERSION=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | jq -r .tag_name | tr -d '\r\n ')

if [ -z "$VERSION" ] || [ "$VERSION" == "null" ]; then
    echo "[!] Error: Could not fetch the latest version tag. Check your internet connection."
    exit 1
fi

echo "[+] Latest version found: $VERSION"
BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$VERSION"

echo "[+] Preparing the system-wide fonts directory at $FONT_DIR..."
mkdir -p "$FONT_DIR"

# 4. Create a temporary directory to work cleanly
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

# 5. Download and extract each font
for FONT in "${FONTS[@]}"; do
    # Clean the font name to prevent hidden characters from breaking the URL
    FONT=$(echo "$FONT" | tr -d '\r\n ')
    
    echo "========================================="
    echo "[+] Downloading $FONT Nerd Font ($VERSION)..."
    
    DOWNLOAD_URL="$BASE_URL/$FONT.zip"
    
    # Use curl with -f (fail fast), -L (follow redirects), and -# (progress bar)
    if curl -fL -# "$DOWNLOAD_URL" -o "$FONT.zip"; then
        echo "[+] Extracting $FONT..."
        
        # Create a specific subdirectory to keep the font family organized
        mkdir -p "$FONT_DIR/$FONT"
        
        # Extract suppressing standard output (-q) and forcing overwrite (-o)
        unzip -qo "$FONT.zip" -d "$FONT_DIR/$FONT"
        
        echo "[✓] $FONT installed successfully."
    else
        echo "[X] Error downloading $FONT. Network issue or file not found."
    fi
done

# 6. System cleanup
echo "========================================="
echo "[+] Cleaning up temporary files..."
rm -rf "$TMP_DIR"

# 7. Rebuild the system font cache
echo "[+] Updating system font cache (fc-cache)..."
fc-cache -fv | grep "NerdFonts"

echo "========================================="
echo "[✓] System-wide installation completed successfully!"
