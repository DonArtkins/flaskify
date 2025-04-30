# Windows Installer for Flaskify
$installDir = "$env:USERPROFILE\.flaskify"
$binDir = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$repoUrl = "https://github.com/DonArtkins/flaskify.git"
$branch = "master"

# Check for Git
try {
    git --version | Out-Null
} catch {
    Write-Host "Error: Git is required but not installed. Please install Git first." -ForegroundColor Red
    exit 1
}

# Create installation directory
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# Clone the repository
Write-Host "Cloning Flaskify repository..."
if (Test-Path "$installDir\.git") {
    # Already a git repo, just pull latest changes
    try {
        Set-Location $installDir
        git pull
    } catch {
        Write-Host "Failed to update existing repository. Attempting to re-clone..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force "$installDir\*" -ErrorAction SilentlyContinue
        git clone --depth=1 -b $branch $repoUrl $installDir
    }
} else {
    # Fresh clone
    Remove-Item -Recurse -Force "$installDir\*" -ErrorAction SilentlyContinue
    git clone --depth=1 -b $branch $repoUrl $installDir
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to clone repository. Please check your internet connection and try again." -ForegroundColor Red
    exit 1
}

# Install Python dependencies
Write-Host "Installing Python dependencies..."
try {
    Set-Location $installDir
    pip install -r requirements.txt
    
    # Install package in development mode
    pip install -e .
} catch {
    Write-Host "Failed to install Python dependencies: $_" -ForegroundColor Red
    exit 1
}

# Create flaskify.cmd in Windows Apps directory
@"
@echo off
python -m flaskify.cli %*
"@ | Out-File -FilePath "$binDir\flaskify.cmd" -Encoding ASCII -Force

Write-Host "Flaskify installed successfully! 🚀" -ForegroundColor Green
Write-Host "Run 'flaskify create <project-name>' to create a new API project"  
Write-Host "Run 'flaskify info' to see available templates and options"