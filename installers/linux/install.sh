#!/bin/bash

INSTALL_DIR="$HOME/.flaskify"
BIN_DIR="/usr/local/bin"
REPO_URL="https://github.com/DonArtkins/flaskify"
BRANCH="master"
VENV_DIR="$INSTALL_DIR/venv"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check for sudo
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Check for required tools
command -v git >/dev/null 2>&1 || { echo -e "${RED}Error: git is required but not installed. Please install git first.${NC}"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo -e "${RED}Error: python3 is required but not installed. Please install python3 first.${NC}"; exit 1; }

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Clone the repository
echo -e "${GREEN}Cloning Flaskify repository...${NC}"
if [ -d "$INSTALL_DIR/.git" ]; then
    # Already a git repo, just pull latest changes
    cd "$INSTALL_DIR" && git pull
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Failed to update existing repository. Attempting to re-clone...${NC}"
        rm -rf "$INSTALL_DIR"
        git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
    fi
else
    # Fresh clone
    rm -rf "$INSTALL_DIR"/*
    git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to clone repository. Please check your internet connection and try again.${NC}"
    exit 1
fi

# Set up virtual environment
echo -e "${GREEN}Setting up Python virtual environment...${NC}"
if [ -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}Existing virtual environment found. Updating...${NC}"
else
    echo -e "${GREEN}Creating new virtual environment...${NC}"
    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Virtual environment creation failed. Trying to install python3-venv...${NC}"
        $SUDO apt-get update && $SUDO apt-get install -y python3-venv
        python3 -m venv "$VENV_DIR"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to create virtual environment. Please install python3-venv manually.${NC}"
            exit 1
        fi
    fi
fi

# Activate virtual environment and install dependencies
echo -e "${GREEN}Installing Python dependencies in virtual environment...${NC}"
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$INSTALL_DIR/requirements.txt"

# Install package in development mode
cd "$INSTALL_DIR" && pip install -e .

# Create flaskify command wrapper
cat > "$INSTALL_DIR/flaskify-cmd" << EOF
#!/bin/bash
# Activate the Flaskify virtual environment and run the CLI
source "$VENV_DIR/bin/activate"
python -m flaskify.cli "\$@"
EOF

chmod +x "$INSTALL_DIR/flaskify-cmd"

# Create symlink to ensure command is available
$SUDO ln -sf "$INSTALL_DIR/flaskify-cmd" "$BIN_DIR/flaskify"

echo -e "${GREEN}Flaskify installed successfully! 🚀${NC}"
echo "Run 'flaskify create <project-name>' to create a new API project"
echo "Run 'flaskify info' to see available templates and options"