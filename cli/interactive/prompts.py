# cli/interactive/prompts.py
import inquirer

def get_project_options():
    """
    Prompt the user for project configuration options.
    """
    questions = [
        inquirer.Text('project_name',
                     message="What is your project named?",
                     validate=lambda _, x: len(x) > 0),
        inquirer.List('version',
                     message="Which version of Flaskify do you want to use?",
                     choices=['v1.0.0', 'v1.0.1', 'v1.0.2']),
        inquirer.Confirm('use_typescript',
                        message="Would you like to use TypeScript?",
                        default=False),
        inquirer.Confirm('use_eslint',
                        message="Would you like to use ESLint?",
                        default=True),
        inquirer.Confirm('use_tailwind',
                        message="Would you like to use Tailwind CSS?",
                        default=False),
        inquirer.Confirm('use_src_dir',
                        message="Would you like your code inside a 'src/' directory?",
                        default=True),
        inquirer.Confirm('use_router',
                        message="Would you like to use App Router? (recommended)",
                        default=True),
        inquirer.List('database',
                     message="Select a database integration:",
                     choices=['None', 'MongoDB', 'PostgreSQL', 'Firebase', 'Supabase']),
        inquirer.Confirm('use_ml',
                        message="Would you like to add ML model support?",
                        default=False),
        inquirer.List('deployment_target',
                     message="Select primary deployment target:",
                     choices=['None', 'Docker', 'Heroku', 'AWS'])
    ]
    
    return inquirer.prompt(questions)

def confirm_options(options):
    """
    Show a summary of selected options and ask for confirmation.
    """
    print("\nProject Configuration Summary:")
    print(f"- Project Name: {options['project_name']}")
    print(f"- Flaskify Version: {options['version']}")
    print(f"- TypeScript: {'Yes' if options['use_typescript'] else 'No'}")
    print(f"- ESLint: {'Yes' if options['use_eslint'] else 'No'}")
    print(f"- Tailwind CSS: {'Yes' if options['use_tailwind'] else 'No'}")
    print(f"- src/ Directory: {'Yes' if options['use_src_dir'] else 'No'}")
    print(f"- App Router: {'Yes' if options['use_router'] else 'No'}")
    print(f"- Database: {options['database']}")
    print(f"- ML Support: {'Yes' if options['use_ml'] else 'No'}")
    print(f"- Deployment Target: {options['deployment_target']}")
    
    questions = [
        inquirer.Confirm('confirm',
                        message="Do you want to proceed with these settings?",
                        default=True),
    ]
    
    return inquirer.prompt(questions)['confirm']