#!/bin/bash

# User-level fonts directory (recommended to avoid requiring root)
FONT_DIR="$HOME/.local/share/fonts/NerdFonts"

# Exact names of the .zip files in the repository
FONTS=("Hack" "Gohu" "Iosevka" "IosevkaTerm" "AnonymousPro")

# 1. Check required dependencies (added 'curl' and 'jq' to parse the API safely)
for cmd in wget unzip fc-cache; do
    if ! command -v $cmd &> /dev/null; then
        echo "[!] Error: the command '$cmd' is not installed."
        echo "    Install it using: sudo apt install $cmd"
        exit 1
    fi
done

# 2. Dynamically fetch the latest release tag from GitHub API
echo "[+] Fetching the latest Nerd Fonts release tag..."
VERSION=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | jq -r .tag_name)

if [ -z "$VERSION" ] || [ "$VERSION" == "null" ]; then
	echo "[!] Error: Could not fetch the latest version tag. Check your internet connection."
	exit 1
fi

echo "[+] Latest version found: $VERSION"
BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$VERSION"

echo "[+] Preparing the fonts directory at $FONT_DIR..."
mkdir -p "$FONT_DIR"

# 3. Create a temporary directory to work cleanly
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

# 4. Download and extract each font
for FONT in "${FONTS[@]}"; do
    echo "========================================="
    echo "[+] Downloading $FONT Nerd Font ($VERSION)..."
    
    if wget -q --show-progress "$BASE_URL/$FONT.zip" -O "$FONT.zip"; then
        echo "[+] Extracting $FONT..."
        
        # Create a specific subdirectory
        mkdir -p "$FONT_DIR/$FONT"
        
	# Extract suppressing standard output (-q) and forcing overwrite (-o)
        unzip -qo "$FONT.zip" -d "$FONT_DIR/$FONT"
        
        echo "$FONT installed successfully."
    else
        echo "Error downloading $FONT. The file might not exist in this release."
    fi
done

# 5. System cleanup
echo "========================================="
echo "[+] Cleaning up temporary files..."
rm -rf "$TMP_DIR"

# 6. Rebuild the font cache
echo "[+] Updating system font cache (fc-cache)..."
fc-cache -fv | grep "$FONT_DIR"

echo "========================================="
echo "Installation completed successfully!"
