# cli/interactive/templates.py
import os
import shutil
from pathlib import Path
import json
import sys

class TemplateAssembler:
    """
    Handles the assembly of template files based on user options.
    """
    def __init__(self, base_dir=None):
        """Initialize with optional base directory."""
        if base_dir is None:
            self.base_dir = Path(__file__).parent.parent.parent
        else:
            self.base_dir = Path(base_dir)
        
        self.templates_dir = self.base_dir / "templates"
    
    def get_template_paths(self, options):
        """
        Get a list of template paths based on user options.
        
        Args:
            options (dict): User selected options
        
        Returns:
            list: List of template directory paths
        """
        version = options['version']
        template_paths = []
        
        # Always include basic template
        basic_path = self.templates_dir / version / 'basic'
        if not basic_path.exists():
            raise FileNotFoundError(f"Basic template for version {version} not found at {basic_path}")
        template_paths.append(basic_path)
        
        # Add database template if selected
        if options['database'] != 'None':
            db_template = f"with_{options['database'].lower()}"
            db_path = self.templates_dir / version / db_template
            if db_path.exists():
                template_paths.append(db_path)
        
        # Add ML template if selected
        if options['use_ml']:
            ml_path = self.templates_dir / version / 'with_ml'
            if ml_path.exists():
                template_paths.append(ml_path)
        
        # Add authentication template if selected
        if options.get('add_authentication', False):
            auth_type = options.get('auth_type', 'JWT').lower()
            auth_path = self.templates_dir / version / f"with_{auth_type}"
            if auth_path.exists():
                template_paths.append(auth_path)
        
        # Add deployment template if selected
        if options['deployment_target'] != 'None':
            deploy_template = f"deploy_{options['deployment_target'].lower()}"
            deploy_path = self.templates_dir / version / deploy_template
            if deploy_path.exists():
                template_paths.append(deploy_path)
        
        # Add swagger template if selected
        if options.get('add_swagger', False):
            swagger_path = self.templates_dir / version / 'with_swagger'
            if swagger_path.exists():
                template_paths.append(swagger_path)
        
        # Add async template if selected
        if options.get('use_async', False):
            async_path = self.templates_dir / version / 'with_async'
            if async_path.exists():
                template_paths.append(async_path)
        
        # Add testing template if selected
        if options.get('add_tests', True):
            test_path = self.templates_dir / version / 'with_testing'
            if test_path.exists():
                template_paths.append(test_path)
                
        return template_paths
    
    def assemble_template(self, project_dir, template_paths):
        """
        Copy and merge template files into the project directory.
        
        Args:
            project_dir (Path): Target project directory
            template_paths (list): List of template directory paths
        """
        # Keep track of copied files to avoid overwriting
        copied_files = {}
        
        for template_path in template_paths:
            self._copy_template_path(template_path, project_dir, copied_files)
        
        # Process any merge files
        self._process_merge_files(project_dir)
        
        # Make script files executable
        self._make_scripts_executable(project_dir)
    
    def _make_scripts_executable(self, project_dir):
        """
        Make script files executable (Unix systems only).
        
        Args:
            project_dir (Path): Project directory
        """
        if sys.platform != 'win32':
            for script_file in project_dir.glob('**/*.sh'):
                script_file.chmod(script_file.stat().st_mode | 0o111)
    
    def _process_merge_files(self, project_dir):
        """
        Process any .merge files to combine content from multiple templates.
        
        Args:
            project_dir (Path): Project directory
        """
        for merge_file in project_dir.glob('**/*.merge'):
            target_file = merge_file.with_suffix('')
            
            # Read merge instructions and content
            try:
                with open(merge_file, 'r', encoding='utf-8') as f:
                    merge_data = json.load(f)
                
                # If target file exists, read it first
                existing_content = ""
                if target_file.exists():
                    with open(target_file, 'r', encoding='utf-8') as f:
                        existing_content = f.read()
                
                # Process merge operations
                final_content = existing_content
                for op in merge_data.get('operations', []):
                    if op['type'] == 'append':
                        final_content += op['content']
                    elif op['type'] == 'prepend':
                        final_content = op['content'] + final_content
                    elif op['type'] == 'replace':
                        if op['target'] in final_content:
                            final_content = final_content.replace(op['target'], op['content'])
                        else:
                            print(f"Warning: Target '{op['target']}' not found in {target_file}")
                    elif op['type'] == 'insert_after':
                        if op['target'] in final_content:
                            final_content = final_content.replace(op['target'], 
                                                                 op['target'] + op['content'])
                        else:
                            print(f"Warning: Target '{op['target']}' not found in {target_file}")
                
                # Write the merged content back
                with open(target_file, 'w', encoding='utf-8') as f:
                    f.write(final_content)
                
                # Remove the merge file
                merge_file.unlink()
                
            except Exception as e:
                print(f"Error processing merge file {merge_file}: {e}")
    
    def _copy_template_path(self, template_path, project_dir, copied_files):
        """
        Copy files from a template path to the project directory.
        
        Args:
            template_path (Path): Source template directory
            project_dir (Path): Target project directory
            copied_files (dict): Dict of already copied files with their source paths
        """
        if not template_path.exists():
            print(f"Warning: Template path {template_path} does not exist.")
            return
            
        for item in template_path.glob('**/*'):
            # Get the relative path from the template directory
            relative_path = item.relative_to(template_path)
            target_path = project_dir / relative_path
            
            # Skip if .merge file - we'll process those separately
            if item.suffix == '.merge':
                # Make sure parent directories exist
                target_path.parent.mkdir(exist_ok=True, parents=True)
                shutil.copy2(item, target_path)
                continue
                
            if item.is_dir():
                target_path.mkdir(exist_ok=True, parents=True)
            else:
                # Create parent directories if they don't exist
                target_path.parent.mkdir(exist_ok=True, parents=True)
                
                # Check if file already copied from another template
                if str(target_path) in copied_files:
                    # This file was already copied, we might need to merge
                    # For now, later templates override earlier ones
                    prior_source = copied_files[str(target_path)]
                    print(f"Note: File {target_path} already copied from {prior_source}, overriding with {item}")
                
                # Copy the file
                shutil.copy2(item, target_path)
                copied_files[str(target_path)] = item
    
    def customize_template(self, project_dir, options):
        """
        Customize template files with user options.
        
        Args:
            project_dir (Path): Project directory
            options (dict): User options
        """
        replacements = {
            "PROJECT_NAME": options['project_name'],
            "FLASKIFY_VERSION": options['version'],
            "DATABASE_TYPE": options['database'],
            "USE_ML": str(options['use_ml']).lower(),
            "DEPLOYMENT_TARGET": options['deployment_target'],
            "USE_AUTHENTICATION": str(options.get('add_authentication', False)).lower(),
            "AUTH_TYPE": options.get('auth_type', 'JWT'),
            "USE_SWAGGER": str(options.get('add_swagger', False)).lower(),
            "USE_ASYNC": str(options.get('use_async', False)).lower(),
            "USE_TESTING": str(options.get('add_tests', True)).lower(),
        }
        
        # Find all text files and replace placeholders
        for path in project_dir.glob('**/*'):
            if path.is_file() and self._is_text_file(path):
                try:
                    content = path.read_text(encoding='utf-8')
                    modified = False
                    
                    for key, value in replacements.items():
                        placeholder = f"{{{{ {key} }}}}"
                        if placeholder in content:
                            content = content.replace(placeholder, value)
                            modified = True
                    
                    if modified:
                        path.write_text(content, encoding='utf-8')
                except Exception as e:
                    print(f"Warning: Could not process file {path}: {e}")
    
    def _is_text_file(self, path):
        """Check if a file is likely a text file based on extension."""
        text_extensions = [
            '.py', '.md', '.txt', '.html', '.css', '.js', '.json',
            '.yml', '.yaml', '.env', '.sh', '.bat', '.rst', '.toml',
            '.ini', '.cfg', '.conf', '.gitignore', '.ps1'
        ]
        return path.suffix.lower() in text_extensions