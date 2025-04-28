# cli/__init__.py
import click
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

if __name__ == '__main__':
    cli()