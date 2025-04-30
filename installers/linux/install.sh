#!/bin/bash

INSTALL_DIR="$HOME/.flaskify"
BIN_DIR="/usr/local/bin"
REPO_URL="https://github.com/DonArtkins/flaskify"
BRANCH="master"

# Check for sudo
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Check for required tools
command -v git >/dev/null 2>&1 || { echo "Error: git is required but not installed. Please install git first."; exit 1; }

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Clone the repository
echo "Cloning Flaskify repository..."
if [ -d "$INSTALL_DIR/.git" ]; then
    # Already a git repo, just pull latest changes
    cd "$INSTALL_DIR" && git pull
    if [ $? -ne 0 ]; then
        echo "Failed to update existing repository. Attempting to re-clone..."
        rm -rf "$INSTALL_DIR"
        git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
    fi
else
    # Fresh clone
    rm -rf "$INSTALL_DIR"/*
    git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

if [ $? -ne 0 ]; then
    echo "Failed to clone repository. Please check your internet connection and try again."
    exit 1
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r "$INSTALL_DIR/requirements.txt" || pip install -r "$INSTALL_DIR/requirements.txt"

# Install package in development mode
cd "$INSTALL_DIR" && pip3 install -e . || pip install -e .

# Create flaskify command for systems without pip entry points
cat > "$INSTALL_DIR/flaskify-cmd" << 'EOF'
#!/bin/bash
python3 -m flaskify.cli "$@" || python -m flaskify.cli "$@"
EOF

chmod +x "$INSTALL_DIR/flaskify-cmd"

# Create symlink to ensure command is available
$SUDO ln -sf "$INSTALL_DIR/flaskify-cmd" "$BIN_DIR/flaskify"

echo "Flaskify installed successfully! 🚀"
echo "Run 'flaskify create <project-name>' to create a new API project"
echo "Run 'flaskify info' to see available templates and options"