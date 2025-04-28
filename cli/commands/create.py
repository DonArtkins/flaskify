# cli/commands/create.py
import os
import shutil
import subprocess
import sys
from pathlib import Path
from ..interactive.prompts import get_project_options, confirm_options
from ..interactive.templates import TemplateAssembler
from ..commands.version import update_last_used_version
from ..utils.helpers import error_exit, success_message, warning_message

class ProjectCreator:
    def __init__(self):
        self.base_dir = Path(__file__).parent.parent.parent
        self.template_assembler = TemplateAssembler(self.base_dir)
    
    def create_project(self):
        """Main method to create a new Flaskify project."""
        # Get project options interactively
        options = get_project_options()
        
        # Confirm options with user
        if not confirm_options(options):
            print("Project creation cancelled.")
            return
        
        # Create project directory
        project_name = options['project_name']
        version = options['version']
        
        try:
            # Create the project directory
            project_dir = Path(project_name)
            if project_dir.exists():
                error_exit(f"Directory '{project_name}' already exists")
                
            project_dir.mkdir()
            
            # Get template paths based on options
            template_paths = self.template_assembler.get_template_paths(options)
            
            # Copy and merge template files
            self.template_assembler.assemble_template(project_dir, template_paths)
            
            # Customize template based on options
            self.template_assembler.customize_template(project_dir, options)
            
            # Set up virtual environment
            self._setup_venv(project_dir)
            
            # Install dependencies
            self._install_dependencies(project_dir, options)
            
            # Initialize git repository
            self._init_git(project_dir)
            
            # Update last used version
            update_last_used_version(version)
            
            success_message(f"🚀 Flaskify project '{project_name}' created successfully!")
            self._show_next_steps(project_name)
            
        except Exception as e:
            error_exit(f"Failed to create project: {str(e)}")
    
    def _setup_venv(self, project_dir):
        """Set up a virtual environment for the project."""
        try:
            subprocess.run([sys.executable, '-m', 'venv', 'venv'], 
                          cwd=project_dir, check=True)
        except subprocess.CalledProcessError:
            warning_message("Failed to create virtual environment. Continuing without it.")
    
    def _install_dependencies(self, project_dir, options):
        """Install project dependencies."""
        try:
            # Determine the activation script based on OS
            if sys.platform == 'win32':
                activate_script = project_dir / 'venv' / 'Scripts' / 'activate'
                activate_cmd = f"call {activate_script}"
            else:
                activate_script = project_dir / 'venv' / 'bin' / 'activate'
                activate_cmd = f"source {activate_script}"
            
            # Install requirements
            if sys.platform == 'win32':
                subprocess.run(
                    f"{activate_cmd} && pip install -r requirements.txt", 
                    cwd=project_dir, shell=True, check=True
                )
            else:
                subprocess.run(
                    f"{activate_cmd} && pip install -r requirements.txt", 
                    cwd=project_dir, shell=True, check=True
                )
                
        except subprocess.CalledProcessError:
            warning_message("Failed to install dependencies. You'll need to run 'pip install -r requirements.txt' manually.")
    
    def _init_git(self, project_dir):
        """Initialize a git repository for the project."""
        try:
            subprocess.run(['git', 'init'], cwd=project_dir, check=True)
            subprocess.run(['git', 'add', '.'], cwd=project_dir, check=True)
            subprocess.run(['git', 'commit', '-m', "Initial commit: Created with Flaskify"],
                          cwd=project_dir, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            warning_message("Git is not installed or an error occurred. Skipping repository initialization.")
    
    def _show_next_steps(self, project_name):
        """Show the user what to do next."""
        print("\nNext steps:")
        print(f"1. cd {project_name}")
        
        if sys.platform == 'win32':
            print("2. .\\venv\\Scripts\\activate")
        else:
            print("2. source venv/bin/activate")
            
        print("3. python run.py")
        print("\nYour API will be available at: http://localhost:5000")