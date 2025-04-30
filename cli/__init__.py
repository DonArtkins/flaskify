# cli/__init__.py
import click
import os
from pathlib import Path
from .commands.create import ProjectCreator
from .commands.version import list_versions, set_default_version

@click.group()
def cli():
    """Flaskify - A Flask REST API generator with built-in versioning and customization."""
    pass

@cli.command()
def create():
    """Create a new Flaskify project interactively."""
    creator = ProjectCreator()
    creator.create_project()

@cli.command()
def versions():
    """List available Flaskify versions."""
    list_versions()

@cli.command()
@click.argument('version')
def set_version(version):
    """Set the default Flaskify version to use."""
    set_default_version(version)

@cli.command()
def info():
    """Display information about Flaskify."""
    print("Flaskify - Flask REST API Generator")
    print("----------------------------------")
    print("A tool for quickly generating Flask REST APIs with")
    print("built-in support for versioning, databases, and more.")
    print("\nAvailable template versions:")
    list_versions()
    
    # Get installation path
    base_dir = Path(__file__).parent.parent
    print(f"\nInstalled in: {base_dir}")
    
    # Check for available templates
    templates_dir = base_dir / "templates"
    if templates_dir.exists():
        template_count = sum(1 for _ in templates_dir.glob('**/template.sh'))
        print(f"Found {template_count} templates")
    else:
        print("No templates found.")

if __name__ == '__main__':
    cli()