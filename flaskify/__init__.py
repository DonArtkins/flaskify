"""
Flaskify Core Package
Developer: Don Artkins
Version Management System
"""

import importlib
from warnings import warn

# Default version if not specified
__version__ = "1.0.0"
__author__ = "Don Artkins"

def load_version(version):
    """
    Dynamically load version-specific implementation
    """
    try:
        return importlib.import_module(f'versioned.{version}')
    except ImportError:
        warn(f"Version {version} not found - using default {__version__}")
        return importlib.import_module(f'versioned.{__version__}')
