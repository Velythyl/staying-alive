#!/bin/bash

set -e

# Defaults
INSTALL_DIR="$HOME/.staying-alive"
PERIOD="1w"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -p|--period)
            PERIOD="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

# Create install dir and files
mkdir -p "$INSTALL_DIR"
touch "$INSTALL_DIR/to_keep_alive.txt"
touch "$INSTALL_DIR/staying_alive_timestamps.log"

# Copy scripts to ~/.local/bin
mkdir -p "$HOME/.local/bin"
cp src/poke_files "$HOME/.local/bin/poke_files"
cp src/staying_alive "$HOME/.local/bin/staying_alive"

# Update default variables in staying_alive script
sed -i "s|^INPUT_FILE=.*|INPUT_FILE=\"\${INPUT_FILE:-$INSTALL_DIR/to_keep_alive.txt}\"|" "$HOME/.local/bin/staying_alive"
sed -i "s|^LOG_FILE=.*|LOG_FILE=\"\${LOG_FILE:-$INSTALL_DIR/staying_alive_timestamps.log}\"|" "$HOME/.local/bin/staying_alive"
sed -i "s|^PERIOD=.*|PERIOD=\"\${PERIOD:-$PERIOD}\"|" "$HOME/.local/bin/staying_alive"

chmod +x "$HOME/.local/bin/poke_files" "$HOME/.local/bin/staying_alive"

# Add staying_alive to .bashrc if not already present
if ! grep -q "staying_alive" "$HOME/.bashrc"; then
    echo "# Run staying_alive on login" >> "$HOME/.bashrc"
    echo "staying_alive \\
        --input-file \"$INSTALL_DIR/to_keep_alive.txt\" \\
        --log-file \"$INSTALL_DIR/staying_alive_timestamps.log\" \\
        --period \"$PERIOD\"" >> "$HOME/.bashrc"
else
    echo "Not adding staying_alive to bashrc because it was already there"
fi

echo "Installation complete."
echo "Cache directory: $INSTALL_DIR"
echo "Period: $PERIOD"
echo "staying_alive installed to ~/.local/bin and added to .bashrc"