#!/usr/bin/env bash

# Flaskify - Flask REST API Template Generator
set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handling function
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Success message function
success_message() {
    echo -e "${GREEN}$1${NC}"
}

# Warning message function
warning_message() {
    echo -e "${YELLOW}$1${NC}"
}

# Check if Python 3 is installed
check_python() {
    if ! command -v python3 &> /dev/null; then
        error_exit "Python 3 is not installed. Please install Python 3 to continue."
    fi
}

# Validate project name
validate_project_name() {
    local project_name=$1
    if [[ ! $project_name =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        error_exit "Invalid project name. Use only letters, numbers, underscores, and hyphens. Must start with a letter."
    fi
}

# Main script
PROJECT_NAME=$1

# Check if project name is provided
if [ -z "$PROJECT_NAME" ]; then
    error_exit "Please provide a project name"
fi

# Validate project name
validate_project_name "$PROJECT_NAME"

# Check if Python 3 is installed
check_python

# Check if project directory already exists
if [ -d "$PROJECT_NAME" ]; then
    error_exit "Directory '$PROJECT_NAME' already exists"
fi

# Create project directory
mkdir -p "$PROJECT_NAME" || error_exit "Failed to create project directory"
cd "$PROJECT_NAME" || error_exit "Failed to enter project directory"

success_message "Creating Flask API project: $PROJECT_NAME"

# Create and activate virtual environment
echo "Creating virtual environment..."
if ! python3 -m venv venv; then
    error_exit "Failed to create virtual environment"
fi

# Source virtual environment based on OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate || error_exit "Failed to activate virtual environment"
else
    source venv/bin/activate || error_exit "Failed to activate virtual environment"
fi

# Create project structure
echo "Creating project structure..."
directories=(
    "app/api/v1"
    "app/utils"
    "app/config"
    "tests"
    "docs"
)

for dir in "${directories[@]}"; do
    mkdir -p "$dir" || error_exit "Failed to create directory: $dir"
done

# Create basic files
touch_files=(
    "app/__init__.py"
    "app/api/__init__.py"
    "app/api/v1/__init__.py"
    "app/api/v1/routes.py"
    "app/utils/__init__.py"
    "app/utils/helpers.py"
    "app/config/__init__.py"
    "app/config/config.py"
    ".env"
    ".gitignore"
    "README.md"
    "LICENSE"
    "CONTRIBUTING.md"
    "requirements.txt"
)

for file in "${touch_files[@]}"; do
    touch "$file" || error_exit "Failed to create file: $file"
done

# Create core requirements file
cat > requirements.txt << EOF
Flask==3.0.0
Flask-RESTful==0.3.10
Flask-CORS==4.0.0
python-dotenv==1.0.0
requests==2.31.0
transformers==4.36.0
Pillow==10.1.0
huggingface-hub==0.19.4
pytest==7.4.3
black==23.11.0
flake8==6.1.0
python-dotenv==1.0.0
EOF

# Create main app
cat > app/__init__.py << EOF
from flask import Flask
from flask_restful import Api
from flask_cors import CORS
from app.config.config import Config

def create_app(config_class=Config):
    """Create and configure the Flask application."""
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Initialize extensions
    CORS(app)
    api = Api(app)

    # Register blueprints/resources
    from app.api.v1 import bp as api_v1
    app.register_blueprint(api_v1, url_prefix='/api/v1')

    @app.route('/')
    def index():
        """Root endpoint with API information."""
        return {
            'api_name': app.config['API_TITLE'],
            'version': app.config['API_VERSION'],
            'status': 'operational',
            'docs_url': '/api/v1/docs'
        }

    return app
EOF

# Create config
cat > app/config/config.py << EOF
import os
import secrets
from datetime import timedelta
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '../../.env'))

class Config:
    """Application configuration class."""
    SECRET_KEY = os.getenv('SECRET_KEY', secrets.token_hex(32))
    API_TITLE = os.getenv('API_TITLE', '$PROJECT_NAME API')
    API_VERSION = os.getenv('API_VERSION', 'v1')
    RATE_LIMIT = int(os.getenv('RATE_LIMIT', 1000))
    RATE_LIMIT_PERIOD = timedelta(minutes=int(os.getenv('RATE_LIMIT_PERIOD', 15)))
    DEBUG = os.getenv('FLASK_DEBUG', 'False').lower() in ('true', '1', 't')
    TESTING = False

class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True

class TestingConfig(Config):
    """Testing configuration."""
    TESTING = True
    DEBUG = True

class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False

# Configuration dictionary
config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
EOF

# Create API blueprint
cat > app/api/v1/__init__.py << EOF
from flask import Blueprint
from flask_restful import Api

bp = Blueprint('api_v1', __name__)
api = Api(bp)

from app.api.v1 import routes
EOF

# Create sample routes with rate limiting
cat > app/api/v1/routes.py << EOF
from flask import request, current_app, jsonify
from flask_restful import Resource
from app.api.v1 import api
from app.utils.helpers import rate_limit
from datetime import datetime

class HealthCheck(Resource):
    @rate_limit
    def get(self):
        """Health check endpoint."""
        return {
            'status': 'healthy',
            'version': current_app.config['API_VERSION'],
            'timestamp': datetime.utcnow().isoformat(),
            'environment': current_app.config['ENV']
        }, 200

class HelloWorld(Resource):
    @rate_limit
    def get(self):
        """Example endpoint."""
        return {
            'message': 'Hello, World!',
            'timestamp': datetime.utcnow().isoformat()
        }, 200

    @rate_limit
    def post(self):
        """Example POST endpoint."""
        data = request.get_json()
        return {
            'message': f"Received: {data}",
            'timestamp': datetime.utcnow().isoformat()
        }, 201

# Register routes
api.add_resource(HealthCheck, '/health')
api.add_resource(HelloWorld, '/hello')
EOF

# Create helpers with rate limiting
cat > app/utils/helpers.py << EOF
from functools import wraps
from flask import request, current_app
import time
from collections import defaultdict
import threading

class RateLimiter:
    def __init__(self):
        self.request_counts = defaultdict(list)
        self.lock = threading.Lock()

    def is_rate_limited(self, ip):
        with self.lock:
            now = time.time()
            window = current_app.config['RATE_LIMIT_PERIOD'].total_seconds()
            
            # Clean old requests
            self.request_counts[ip] = [
                req_time for req_time in self.request_counts[ip]
                if now - req_time < window
            ]
            
            # Check rate limit
            if len(self.request_counts[ip]) >= current_app.config['RATE_LIMIT']:
                return True
                
            self.request_counts[ip].append(now)
            return False

rate_limiter = RateLimiter()

def rate_limit(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        ip = request.remote_addr
        
        if rate_limiter.is_rate_limited(ip):
            return {
                'error': 'Rate limit exceeded',
                'retry_after': current_app.config['RATE_LIMIT_PERIOD'].total_seconds()
            }, 429
            
        return f(*args, **kwargs)
    return decorated_function
EOF

# Create run.py
cat > run.py << EOF
import os
from app import create_app
from app.config.config import config

# Get environment from FLASK_ENV, default to 'development'
env = os.getenv('FLASK_ENV', 'development')
app = create_app(config[env])

if __name__ == '__main__':
    host = os.getenv('FLASK_HOST', '0.0.0.0')
    port = int(os.getenv('FLASK_PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'False').lower() in ('true', '1', 't')
    
    app.run(host=host, port=port, debug=debug)
EOF

# Create .gitignore
cat > .gitignore << EOF
# Python
*.py[cod]
__pycache__/
*.so
.Python
*.egg
*.egg-info/
dist/
build/
eggs/
parts/
bin/
var/
sdist/
develop-eggs/
.installed.cfg
lib/
lib64/
venv/
.env

# IDE
.idea/
.vscode/
*.swp
*.swo
.DS_Store

# Testing
.coverage
.tox/
.pytest_cache/
htmlcov/

# Logs
*.log
logs/
EOF

# Create .env template
cat > .env << EOF
# Flask Configuration
FLASK_APP=run.py
FLASK_ENV=development
FLASK_DEBUG=True
FLASK_HOST=0.0.0.0
FLASK_PORT=5000

# API Configuration
API_TITLE=$PROJECT_NAME API
API_VERSION=v1
RATE_LIMIT=1000
RATE_LIMIT_PERIOD=15

# Security
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
EOF

# Install requirements
echo "Installing requirements..."
if ! pip install -r requirements.txt; then
    error_exit "Failed to install requirements"
fi

# Initialize git repository
echo "Initializing git repository..."
if command -v git &> /dev/null; then
    git init
    git add .
    git commit -m "Initial commit: Flaskify template"
else
    warning_message "Git is not installed. Skipping repository initialization."
fi

success_message "🚀 Flaskify project '${PROJECT_NAME}' created successfully!"
echo ""
echo "Project structure created and dependencies installed."
echo ""
echo "To start the API:"
echo "1. cd ${PROJECT_NAME}"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "2. .\\venv\\Scripts\\activate"
else
    echo "2. source venv/bin/activate"
fi
echo "3. python run.py"
echo ""
echo "Your API will be available at: http://localhost:5000"
echo "API endpoints:"
echo "- Health check: http://localhost:5000/api/v1/health"
echo "- Example endpoint: http://localhost:5000/api/v1/hello"
echo ""
echo "Happy coding! 🎉"