# cli/interactive/prompts.py
import inquirer
from ..commands.version import get_versions, get_default_version

def get_project_options():
    """
    Prompt the user for project configuration options.
    Returns a dictionary of user selections.
    """
    # Get available versions
    versions = get_versions()
    default_version = get_default_version()
    
    questions = [
        inquirer.Text('project_name',
                     message="What is your project named?",
                     validate=lambda _, x: len(x) > 0),
        inquirer.List('version',
                     message="Which version of Flaskify do you want to use?",
                     choices=versions,
                     default=default_version),
        inquirer.List('database',
                     message="Select a database integration:",
                     choices=['None', 'MongoDB', 'PostgreSQL', 'Firebase', 'Supabase']),
        inquirer.Confirm('use_ml',
                        message="Would you like to add ML model support?",
                        default=False),
        inquirer.List('deployment_target',
                     message="Select primary deployment target:",
                     choices=['None', 'Docker', 'Heroku', 'AWS']),
        inquirer.Confirm('add_authentication',
                        message="Would you like to add authentication support?",
                        default=True),
        inquirer.List('auth_type',
                     message="Select authentication type:",
                     choices=['JWT', 'OAuth2', 'Basic'],
                     default='JWT',
                     when=lambda answers: answers.get('add_authentication', False)),
        inquirer.Confirm('add_swagger',
                        message="Would you like to add Swagger documentation?",
                        default=True),
        inquirer.Confirm('use_async',
                        message="Would you like to use asynchronous endpoints (requires Python 3.7+)?",
                        default=False),
        inquirer.Confirm('add_tests',
                        message="Would you like to set up testing with pytest?",
                        default=True)
    ]
    
    return inquirer.prompt(questions)

def confirm_options(options):
    """
    Show a summary of selected options and ask for confirmation.
    """
    print("\nProject Configuration Summary:")
    print(f"- Project Name: {options['project_name']}")
    print(f"- Flaskify Version: {options['version']}")
    print(f"- Database: {options['database']}")
    print(f"- ML Support: {'Yes' if options['use_ml'] else 'No'}")
    print(f"- Deployment Target: {options['deployment_target']}")
    print(f"- Authentication: {'Yes - ' + options.get('auth_type', 'None') if options.get('add_authentication') else 'No'}")
    print(f"- Swagger Documentation: {'Yes' if options.get('add_swagger') else 'No'}")
    print(f"- Async Endpoints: {'Yes' if options.get('use_async') else 'No'}")
    print(f"- Testing Setup: {'Yes' if options.get('add_tests') else 'No'}")
    
    questions = [
        inquirer.Confirm('confirm',
                        message="Do you want to proceed with these settings?",
                        default=True),
    ]
    
    return inquirer.prompt(questions)['confirm']