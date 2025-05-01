#!/bin/bash

INSTALL_DIR="$HOME/.flaskify"
BIN_DIR="/usr/local/bin"
REPO_URL="https://github.com/DonArtkins/flaskify"
BRANCH="master"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check for sudo
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Silent output function
silent_output() {
    "$@" > /dev/null 2>&1
}

# Check for required tools
command -v git >/dev/null 2>&1 || { echo -e "${RED}Error: git is required but not installed. Please install git first.${NC}"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo -e "${RED}Error: python3 is required but not installed. Please install python3 first.${NC}"; exit 1; }

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Clone the repository
echo -e "${GREEN}Installing Flaskify...${NC}"
if [ -d "$INSTALL_DIR/.git" ]; then
    # Already a git repo, just pull latest changes silently
    (cd "$INSTALL_DIR" && silent_output git pull)
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Updating repository...${NC}"
        rm -rf "$INSTALL_DIR"
        silent_output git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
    fi
else
    # Fresh clone silently
    rm -rf "$INSTALL_DIR"/*
    silent_output git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to download Flaskify. Please check your internet connection and try again.${NC}"
    exit 1
fi

# Create proper package structure (NEW STEP)
echo -e "${GREEN}Setting up package structure...${NC}"
mkdir -p "$INSTALL_DIR/flaskify"
touch "$INSTALL_DIR/flaskify/__init__.py"

# Move cli directory into flaskify if it's not already there
if [ -d "$INSTALL_DIR/cli" ] && [ ! -d "$INSTALL_DIR/flaskify/cli" ]; then
    cp -r "$INSTALL_DIR/cli" "$INSTALL_DIR/flaskify/"
    touch "$INSTALL_DIR/flaskify/cli/__init__.py"
fi

# Create a virtual environment within the Flaskify installation
echo -e "${GREEN}Setting up Flaskify environment...${NC}"
silent_output python3 -m venv "$INSTALL_DIR/venv"

# Use the virtual environment's pip to install dependencies
VENV_PIP="$INSTALL_DIR/venv/bin/pip"
silent_output "$VENV_PIP" install -U pip setuptools wheel
silent_output "$VENV_PIP" install -r "$INSTALL_DIR/requirements.txt"

# Install the package in development mode within the virtual environment
(cd "$INSTALL_DIR" && silent_output "$VENV_PIP" install -e .)

# Create flaskify command launcher
cat > "$INSTALL_DIR/flaskify-cmd" << 'EOF'
#!/bin/bash
# Path to the virtual environment's Python
VENV_PYTHON="$HOME/.flaskify/venv/bin/python"

# Run the flaskify command using the virtual environment's Python
"$VENV_PYTHON" -m flaskify.cli "$@"

# Exit with the same code as the Python script
exit $?
EOF

chmod +x "$INSTALL_DIR/flaskify-cmd"

# Create symlink to ensure command is available
echo -e "${GREEN}Making Flaskify available system-wide...${NC}"
$SUDO ln -sf "$INSTALL_DIR/flaskify-cmd" "$BIN_DIR/flaskify"

echo -e "${GREEN}✅ Flaskify installed successfully! 🚀${NC}"
echo "Run 'flaskify create <project-name>' to create a new API project"
echo "Run 'flaskify info' to see available templates and options"