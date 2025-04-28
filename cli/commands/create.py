# cli/commands/create.py
import os
import shutil
import subprocess
import sys
from pathlib import Path
from ..interactive.prompts import get_project_options, confirm_options
from ..utils.helpers import error_exit, success_message, warning_message

class ProjectCreator:
    def __init__(self):
        self.base_dir = Path(__file__).parent.parent.parent
        self.templates_dir = self.base_dir / "templates"
    
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
            
            # Select the appropriate template based on options
            template_path = self._select_template(options)
            
            # Copy template files
            self._copy_template(template_path, project_dir)
            
            # Customize template based on options
            self._customize_template(project_dir, options)
            
            # Set up virtual environment
            self._setup_venv(project_dir)
            
            # Install dependencies
            self._install_dependencies(project_dir, options)
            
            # Initialize git repository
            self._init_git(project_dir)
            
            success_message(f"🚀 Flaskify project '{project_name}' created successfully!")
            self._show_next_steps(project_name)
            
        except Exception as e:
            error_exit(f"Failed to create project: {str(e)}")
    
    def _select_template(self, options):
        """Select the appropriate template based on user options."""
        version = options['version']
        
        # Base template selection logic
        if options['database'] == 'None' and not options['use_ml']:
            template = 'basic'
        elif options['database'] != 'None' and not options['use_ml']:
            if options['database'] == 'MongoDB':
                template = 'with_mongodb'
            elif options['database'] == 'PostgreSQL':
                template = 'with_postgres'
            else:
                template = 'with_' + options['database'].lower()
        elif options['use_ml']:
            template = 'with_ml'
        else:
            template = 'full'
        
        template_path = self.templates_dir / version / template
        
        if not template_path.exists():
            # Fall back to basic template if specific one doesn't exist
            warning_message(f"Template {template} not found for {version}, using basic template.")
            template_path = self.templates_dir / version / 'basic'
            
        return template_path
    
    def _copy_template(self, template_path, project_dir):
        """Copy template files to the project directory."""
        for item in template_path.glob('*'):
            if item.is_dir():
                shutil.copytree(item, project_dir / item.name)
            else:
                shutil.copy2(item, project_dir / item.name)
    
    def _customize_template(self, project_dir, options):
        """Customize the template based on user options."""
        # Update project name in files
        self._replace_in_files(project_dir, "PROJECT_NAME", options['project_name'])
        
        # Configure database settings if selected
        if options['database'] != 'None':
            self._configure_database(project_dir, options['database'])
        
        # Add ML support if selected
        if options['use_ml']:
            self._configure_ml_support(project_dir)
        
        # Configure deployment settings
        if options['deployment_target'] != 'None':
            self._configure_deployment(project_dir, options['deployment_target'])
    
    def _replace_in_files(self, directory, placeholder, replacement):
        """Replace placeholder text in all project files."""
        for path in directory.glob('**/*'):
            if path.is_file() and path.suffix in ['.py', '.md', '.rst', '.txt', '.sh', '.yml', '.yaml', '.env']:
                try:
                    content = path.read_text()
                    if placeholder in content:
                        path.write_text(content.replace(placeholder, replacement))
                except UnicodeDecodeError:
                    # Skip binary files
                    pass
    
    def _configure_database(self, project_dir, database):
        """Configure the selected database."""
        # Implementation details for each database type
        pass
    
    def _configure_ml_support(self, project_dir):
        """Add machine learning support to the project."""
        # Implementation details for ML support
        pass
    
    def _configure_deployment(self, project_dir, deployment):
        """Configure deployment settings."""
        # Implementation details for each deployment target
        pass
    
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