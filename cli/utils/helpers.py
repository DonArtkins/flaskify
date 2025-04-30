# cli/utils/helpers.py
import sys
import os
import platform

# Color codes for output - cross-platform compatible
if platform.system() == 'Windows':
    # Windows CMD and PowerShell handle colors differently
    try:
        import colorama
        colorama.init()
        RED = '\033[0;31m'
        GREEN = '\033[0;32m'
        YELLOW = '\033[1;33m'
        NC = '\033[0m'  # No Color
    except ImportError:
        # Colorama not installed, use plain text
        RED = ''
        GREEN = ''
        YELLOW = ''
        NC = ''
else:
    # Unix terminals support ANSI color codes
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color

def error_exit(message):
    """Print error message and exit."""
    print(f"{RED}Error: {message}{NC}", file=sys.stderr)
    sys.exit(1)

def success_message(message):
    """Print success message."""
    print(f"{GREEN}{message}{NC}")

def warning_message(message):
    """Print warning message."""
    print(f"{YELLOW}Warning: {message}{NC}")

def ensure_directory_exists(directory_path):
    """Create directory if it doesn't exist."""
    try:
        path = os.path.abspath(directory_path)
        if not os.path.exists(path):
            os.makedirs(path)
            return True
        return False
    except Exception as e:
        error_exit(f"Failed to create directory: {str(e)}")

def is_valid_version_format(version):
    """Check if the version string follows the pattern 'vX.Y.Z'."""
    import re
    pattern = r'^v\d+\.\d+\.\d+$'
    return re.match(pattern, version) is not None

def get_platform_info():
    """Get information about the platform."""
    return {
        'system': platform.system(),
        'release': platform.release(),
        'version': platform.version(),
        'machine': platform.machine(),
        'processor': platform.processor(),
        'python_version': platform.python_version(),
    }