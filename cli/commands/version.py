# cli/commands/version.py
import os
from pathlib import Path
import json
from ..utils.helpers import success_message, error_exit, warning_message

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
        # Get all available versions
        versions = get_versions()
        default_version = versions[0] if versions else "v1.0.0"
        
        # Create default config
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump({
                'default_version': default_version,
                'last_used_version': default_version
            }, f, indent=2)
    
    return config_file

def get_versions():
    """Get all available versions."""
    base_dir = Path(__file__).parent.parent.parent
    templates_dir = base_dir / 'templates'
    
    if not templates_dir.exists():
        warning_message(f"Templates directory not found: {templates_dir}")
        return []
    
    versions = []
    for item in templates_dir.glob('v*.*.*'):
        if item.is_dir():
            versions.append(item.name)
    
    return sorted(versions)

def list_versions():
    """List all available versions and indicate the default."""
    versions = get_versions()
    
    if not versions:
        print("No Flaskify versions found.")
        return
    
    try:
        with open(get_config_file(), 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        default_version = config.get('default_version', versions[0])
        
        print("Available Flaskify versions:")
        for version in versions:
            if version == default_version:
                print(f"* {version} (default)")
            else:
                print(f"  {version}")
    except Exception as e:
        warning_message(f"Error reading config: {str(e)}")
        print("Available Flaskify versions:")
        for version in versions:
            print(f"  {version}")

def set_default_version(version):
    """Set the default version to use."""
    versions = get_versions()
    
    if not versions:
        error_exit("No Flaskify versions found.")
    
    if version not in versions:
        error_exit(f"Version {version} is not available. Available versions: {', '.join(versions)}")
    
    config_file = get_config_file()
    
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        config['default_version'] = version
        
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
        
        success_message(f"Default version set to {version}")
    except Exception as e:
        error_exit(f"Failed to set default version: {str(e)}")

def get_default_version():
    """Get the default version."""
    try:
        with open(get_config_file(), 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        versions = get_versions()
        default_version = config.get('default_version')
        
        # Validate the default version exists
        if default_version not in versions:
            if versions:
                default_version = versions[0]
                warning_message(f"Default version not found. Using {default_version} instead.")
                update_default_version(default_version)
            else:
                error_exit("No Flaskify versions found.")
        
        return default_version
    except Exception as e:
        warning_message(f"Error reading config: {str(e)}")
        versions = get_versions()
        if versions:
            return versions[0]
        else:
            error_exit("No Flaskify versions found.")

def update_default_version(version):
    """Update the default version in the config file."""
    config_file = get_config_file()
    
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        config['default_version'] = version
        
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
    except Exception as e:
        warning_message(f"Failed to update default version: {str(e)}")

def update_last_used_version(version):
    """Update the last used version."""
    config_file = get_config_file()
    
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        config['last_used_version'] = version
        
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
    except Exception as e:
        warning_message(f"Failed to update last used version: {str(e)}")