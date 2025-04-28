# cli/commands/version.py
import os
from pathlib import Path
import json
from ..utils.helpers import success_message, error_exit

def get_config_dir():
    """Get the Flaskify configuration directory."""
    home = Path.home()
    config_dir = home / '.flaskify'
    config_dir.mkdir(exist_ok=True)
    return config_dir

def get_config_file():
    """Get the configuration file path."""
    config_dir = get_config_dir()
    config_file = config_dir / 'config.json'
    
    if not config_file.exists():
        # Create default config
        with open(config_file, 'w') as f:
            json.dump({
                'default_version': 'v1.0.0',
                'last_used_version': 'v1.0.0'
            }, f)
    
    return config_file

def get_versions():
    """Get all available versions."""
    base_dir = Path(__file__).parent.parent.parent
    templates_dir = base_dir / 'templates'
    
    versions = []
    for item in templates_dir.glob('v*.*.*'):
        if item.is_dir():
            versions.append(item.name)
    
    return sorted(versions)

def list_versions():
    """List all available versions and indicate the default."""
    versions = get_versions()
    
    with open(get_config_file(), 'r') as f:
        config = json.load(f)
    
    default_version = config.get('default_version', 'v1.0.0')
    
    print("Available Flaskify versions:")
    for version in versions:
        if version == default_version:
            print(f"* {version} (default)")
        else:
            print(f"  {version}")

def set_default_version(version):
    """Set the default version to use."""
    versions = get_versions()
    
    if version not in versions:
        error_exit(f"Version {version} is not available. Available versions: {', '.join(versions)}")
    
    config_file = get_config_file()
    
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    config['default_version'] = version
    
    with open(config_file, 'w') as f:
        json.dump(config, f)
    
    success_message(f"Default version set to {version}")

def get_default_version():
    """Get the default version."""
    with open(get_config_file(), 'r') as f:
        config = json.load(f)
    
    return config.get('default_version', 'v1.0.0')

def update_last_used_version(version):
    """Update the last used version."""
    config_file = get_config_file()
    
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    config['last_used_version'] = version
    
    with open(config_file, 'w') as f:
        json.dump(config, f)