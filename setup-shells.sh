#!/bin/bash

# Setup script for smart shell switching between zsh and nushell

echo "Setting up smart shell switching..."

# Check if nushell is installed
if ! command -v nu &> /dev/null; then
    echo "❌ Nushell is not installed. Install it with:"
    echo "   brew install nushell"
    exit 1
else
    echo "✅ Nushell found at $(which nu)"
fi

# Check if starship is installed
if ! command -v starship &> /dev/null; then
    echo "❌ Starship is not installed. Install it with:"
    echo "   brew install starship"
    exit 1
else
    echo "✅ Starship found at $(which starship)"
fi

# Check if required directories exist
NUSHELL_CONFIG_DIR="$HOME/.config/nushell"
if [ ! -d "$NUSHELL_CONFIG_DIR" ]; then
    echo "📁 Creating nushell config directory..."
    mkdir -p "$NUSHELL_CONFIG_DIR"
fi

echo "✅ Setup complete!"
echo ""
echo "Usage:"
echo "  From zsh: Run 'nu' (or 'nushell') to switch to nushell"
