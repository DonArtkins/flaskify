# cli/utils/helpers.py
import sys
import os

# Color codes for output
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
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)
        return True
    return False

def is_valid_version_format(version):
    """Check if the version string follows the pattern 'vX.Y.Z'."""
    import re
    pattern = r'^v\d+\.\d+\.\d+$'
    return re.match(pattern, version) is not None