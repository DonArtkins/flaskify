#!/bin/bash

# Flaskify - Flask REST API Template Generator
PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "Please provide a project name"
    exit 1
fi

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate

# Create project structure
mkdir -p app/api/v1
mkdir -p app/utils
mkdir -p app/config
mkdir -p tests
mkdir -p docs

# Create basic files
touch app/__init__.py
touch app/api/__init__.py
touch app/api/v1/__init__.py
touch app/api/v1/routes.py
touch app/utils/__init__.py
touch app/utils/helpers.py
touch app/config/__init__.py
touch app/config/config.py
touch .env
touch .gitignore
touch README.md
touch requirements.txt

# Create core requirements file
cat > requirements.txt << EOF
flask
flask-restful
flask-cors
python-dotenv
requests
transformers
pillow
huggingface-hub
regex
tqdm
EOF

# Create main app
cat > app/__init__.py << EOF
from flask import Flask
from flask_restful import Api
from flask_cors import CORS
from app.config.config import Config

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize extensions
    CORS(app)
    api = Api(app)
    
    # Register blueprints/resources
    from app.api.v1 import bp as api_v1
    app.register_blueprint(api_v1, url_prefix='/api/v1')
    
    return app
EOF

# Create config
cat > app/config/config.py << EOF
import os
from datetime import timedelta
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '../../.env'))

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'your-secret-key')
    API_TITLE = os.getenv('API_TITLE', 'Flaskify API')
    API_VERSION = os.getenv('API_VERSION', 'v1')
    RATE_LIMIT = int(os.getenv('RATE_LIMIT', 1000))
    RATE_LIMIT_PERIOD = timedelta(minutes=int(os.getenv('RATE_LIMIT_PERIOD', 15)))
EOF

# Create API blueprint
cat > app/api/v1/__init__.py << EOF
from flask import Blueprint
from flask_restful import Api

bp = Blueprint('api', __name__)
api = Api(bp)

from app.api.v1 import routes
EOF

# Create sample routes with rate limiting
cat > app/api/v1/routes.py << EOF
from flask import request, current_app
from flask_restful import Resource
from app.api.v1 import api
from app.utils.helpers import rate_limit

class HealthCheck(Resource):
    @rate_limit
    def get(self):
        return {
            'status': 'healthy',
            'version': current_app.config['API_VERSION']
        }, 200

api.add_resource(HealthCheck, '/health')
EOF

# Create helpers with rate limiting
cat > app/utils/helpers.py << EOF
from functools import wraps
from flask import request, current_app
import time
from collections import defaultdict

# Simple in-memory rate limiting
request_counts = defaultdict(list)

def rate_limit(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        ip = request.remote_addr
        now = time.time()
        
        # Clean old requests
        request_counts[ip] = [req_time for req_time in request_counts[ip] 
                            if now - req_time < current_app.config['RATE_LIMIT_PERIOD'].total_seconds()]
        
        # Check rate limit
        if len(request_counts[ip]) >= current_app.config['RATE_LIMIT']:
            return {'error': 'Rate limit exceeded'}, 429
        
        request_counts[ip].append(now)
        return f(*args, **kwargs)
    return decorated_function
EOF

# Create run.py
cat > run.py << EOF
from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(debug=True)
EOF

# Create .gitignore
cat > .gitignore << EOF
*.pyc
__pycache__/
venv/
.env
.vscode/
.idea/
*.log
.DS_Store
EOF

# Create comprehensive README
cat > README.md << EOF
# Flaskify 🚀

A minimalist, high-performance Flask REST API template with built-in rate limiting and best practices.

## Features

- 🚄 High-performance REST API setup
- 🔒 Built-in rate limiting
- 📦 Common AI/ML packages pre-configured
- 🌐 CORS enabled
- 📝 Extensive documentation
- 🔄 Version control ready

## Installation

### Linux/Mac
\`\`\`bash
# Install Flaskify CLI
curl -s https://raw.githubusercontent.com/yourusername/flaskify/main/install.sh | bash

# Create new project
flaskify create my-api
\`\`\`

### Windows
\`\`\`powershell
# Install Flaskify CLI
iwr -useb https://raw.githubusercontent.com/yourusername/flaskify/main/install.ps1 | iex

# Create new project
flaskify create my-api
\`\`\`

## Quick Start

1. Create new project:
   \`\`\`bash
   flaskify create my-api
   cd my-api
   \`\`\`

2. Activate virtual environment:
   \`\`\`bash
   # Linux/Mac
   source venv/bin/activate
   
   # Windows
   .\\venv\\Scripts\\activate
   \`\`\`

3. Install dependencies:
   \`\`\`bash
   pip install -r requirements.txt
   \`\`\`

4. Run the API:
   \`\`\`bash
   python run.py
   \`\`\`

## API Structure

\`\`\`
my-api/
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── __init__.py
│   │       └── routes.py
│   ├── config/
│   │   └── config.py
│   ├── utils/
│   │   └── helpers.py
│   └── __init__.py
├── tests/
├── venv/
├── .env
├── .gitignore
├── README.md
├── requirements.txt
└── run.py
\`\`\`

## Deployment

### Heroku
\`\`\`bash
heroku create my-api
git push heroku main
\`\`\`

### Docker
\`\`\`bash
docker build -t my-api .
docker run -p 5000:5000 my-api
\`\`\`

### Railway
\`\`\`bash
railway init
railway up
\`\`\`

## Rate Limiting

- Default: 1000 requests per 15 minutes
- Configurable via .env:
  \`\`\`
  RATE_LIMIT=1000
  RATE_LIMIT_PERIOD=15
  \`\`\`

## Best Practices

- ✅ RESTful routing
- ✅ Rate limiting
- ✅ Error handling
- ✅ Configuration management
- ✅ API versioning
- ✅ CORS support
- ✅ Clean project structure

## License

MIT

EOF

# Initialize git repository
git init
git add .
git commit -m "Initial commit: Flaskify template"

echo "🚀 Flaskify project '${PROJECT_NAME}' created successfully!"
echo ""
echo "To get started:"
echo "cd ${PROJECT_NAME}"
echo "source venv/bin/activate  # Linux/Mac"
echo "# OR"
echo ".\\venv\\Scripts\\activate  # Windows"
echo "pip install -r requirements.txt"
echo "python run.py"
echo ""
echo "Your API will be available at: http://localhost:5000/api/v1/"
echo "Health check endpoint: http://localhost:5000/api/v1/health"
