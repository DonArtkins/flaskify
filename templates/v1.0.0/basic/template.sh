#!/bin/bash

# Flaskify - Basic Template
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

# Create project structure
echo "Creating basic project structure..."
mkdir -p "app/api/v1"
mkdir -p "app/utils"
mkdir -p "app/config"
mkdir -p "tests"
mkdir -p "docs"

# Create basic files
touch "app/__init__.py"
touch "app/api/__init__.py"
touch "app/api/v1/__init__.py"
touch "app/api/v1/routes.py"
touch "app/utils/__init__.py"
touch "app/utils/helpers.py"
touch "app/config/__init__.py"
touch "app/config/config.py"
touch ".env"
touch ".gitignore"
touch "README.md"
touch "LICENSE"
touch "requirements.txt"

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
    API_TITLE = os.getenv('API_TITLE', '{{ PROJECT_NAME }} API')
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
        environment = current_app.config.get('FLASK_ENV', 'production')
        return {
            'status': 'healthy',
            'version': current_app.config['API_VERSION'],
            'timestamp': datetime.utcnow().isoformat(),
            'environment': environment
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
API_TITLE={{ PROJECT_NAME }} API
API_VERSION=v1
RATE_LIMIT=1000
RATE_LIMIT_PERIOD=15

# Security
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
EOF

# Create basic README
cat > README.md << EOF
# {{ PROJECT_NAME }} 🚀

A Flask API project created with Flaskify.

## Features

- 🚄 High-performance REST API setup
- 🔒 Built-in rate limiting
- 🌐 CORS enabled
- 📝 Clear project structure

## Quick Start

1. Activate the virtual environment:
   \`\`\`
   source venv/bin/activate  # Linux/Mac
   venv\\Scripts\\activate    # Windows
   \`\`\`

2. Install dependencies:
   \`\`\`
   pip install -r requirements.txt
   \`\`\`

3. Run the API:
   \`\`\`
   python run.py
   \`\`\`

Your API will be available at: http://localhost:5000
EOF

# Create requirements.txt
cat > requirements.txt << EOF
Flask==3.0.0
Flask-RESTful==0.3.10
Flask-CORS==4.0.0
python-dotenv==1.0.0
requests==2.31.0
pytest==7.4.3
EOF

echo "Basic template created successfully"