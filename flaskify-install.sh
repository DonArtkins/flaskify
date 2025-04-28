#!/bin/bash

INSTALL_DIR="$HOME/.flaskify"
BIN_DIR="/usr/local/bin"

# Check for sudo
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi


# Create installation directory
mkdir -p "$INSTALL_DIR"

# Download template
curl -s https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-template.sh -o "$INSTALL_DIR/template.sh"
chmod +x "$INSTALL_DIR/template.sh"

# Create flaskify command
cat > "$INSTALL_DIR/flaskify" << 'EOF'
#!/bin/bash

COMMAND=$1
PROJECT_NAME=$2

case $COMMAND in
    "create")
        if [ -z "$PROJECT_NAME" ]; then
            echo "Usage: flaskify create <project-name>"
            exit 1
        fi
        ~/.flaskify/template.sh "$PROJECT_NAME"
        ;;
    *)
        echo "Usage: flaskify create <project-name>"
        exit 1
        ;;
esac
EOF

chmod +x "$INSTALL_DIR/flaskify"

# Create symlink
$SUDO ln -sf "$INSTALL_DIR/flaskify" "$BIN_DIR/flaskify"

echo "Flaskify installed successfully! 🚀"
echo "Run 'flaskify create <project-name>' to create a new API project"