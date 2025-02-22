# install.sh (Linux/Mac)
#!/bin/bash

INSTALL_DIR="$HOME/.flaskify"
BIN_DIR="/usr/local/bin"

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Download template
curl -s https://raw.githubusercontent.com/yourusername/flaskify/main/flaskify-template.sh -o "$INSTALL_DIR/template.sh"
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
sudo ln -sf "$INSTALL_DIR/flaskify" "$BIN_DIR/flaskify"

echo "Flaskify installed successfully! 🚀"
echo "Run 'flaskify create <project-name>' to create a new API project"

# install.ps1 (Windows)
$installDir = "$env:USERPROFILE\.flaskify"
$binDir = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

# Create installation directory
New-Item -ItemType Directory -Force -Path $installDir

# Download template
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/flaskify/main/flaskify-template.sh" -OutFile "$installDir\template.sh"

# Create flaskify.cmd
@"
@echo off
IF "%1"=="create" (
    IF "%2"=="" (
        echo Usage: flaskify create ^<project-name^>
    ) ELSE (
        bash %USERPROFILE%\.flaskify\template.sh %2
    )
) ELSE (
    echo Usage: flaskify create ^<project-name^>
)
"@ | Out-File -FilePath "$binDir\flaskify.cmd" -Encoding ASCII

Write-Host "Flaskify installed successfully! 🚀"
Write-Host "Run 'flaskify create <project-name>' to create a new API project"
