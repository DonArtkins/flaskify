$installDir = "$env:USERPROFILE\.flaskify"
$binDir = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

# Create installation directory
New-Item -ItemType Directory -Force -Path $installDir

# Download template
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-template.sh" -OutFile "$installDir\template.sh" -ErrorAction Stop
} catch {
    Write-Error "Failed to download template: $($_.Exception.Message)"
    exit 1
}

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