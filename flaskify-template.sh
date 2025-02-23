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
python3 -m venv venv  # Use python3 for broader compatibility
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
touch LICENSE
touch CONTRIBUTING.md
touch requirements.txt

# Create core requirements file
cat > requirements.txt << EOF
Flask
Flask-RESTful
Flask-CORS
python-dotenv
requests
transformers
pillow
huggingface-hub
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
    SECRET_KEY = os.getenv('SECRET_KEY', 'your-secret-key')  # Generate a strong key in production!
    API_TITLE = os.getenv('API_TITLE', 'Flaskify API')
    API_VERSION = os.getenv('API_VERSION', 'v1')
    RATE_LIMIT = int(os.getenv('RATE_LIMIT', 1000))
    RATE_LIMIT_PERIOD = timedelta(minutes=int(os.getenv('RATE_LIMIT_PERIOD', 15)))
    # Add more configuration variables as needed (e.g., database URIs)

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

# Example resource (replace with your actual API logic)
class HelloWorld(Resource):
    def get(self):
        return {'message': 'Hello, World!'}, 200

api.add_resource(HelloWorld, '/hello')
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
__pycache__
instance/
.pytest_cache
.env
.DS_Store
*.swp
EOF

# Create comprehensive README
cat > README.md << EOF
# [PROJECT_NAME] API 🚀

This is a Flask REST API project generated using Flaskify.  It provides a solid foundation for building your API with best practices already in place.

## Features

- 🚀 High-performance REST API setup
- 🔒 Built-in rate limiting (configurable)
- 🌐 CORS enabled (for cross-origin requests)
- 📝 Clear project structure
- 🔄 Version control ready
- 📦 Essential dependencies pre-configured

## Getting Started

1.  **Navigate to the Project Directory:**

    \`\`\`bash
    cd [PROJECT_NAME]
    \`\`\`

2.  **Activate the Virtual Environment:**

    \`\`\`bash
    # Linux/Mac
    source venv/bin/activate

    # Windows
    .\\venv\\Scripts\\activate
    \`\`\`

3.  **Install Dependencies:**

    \`\`\`bash
    pip install -r requirements.txt
    \`\`\`

4.  **Run the API (Development):**

    \`\`\`bash
    python run.py
    \`\`\`

    The API will start in debug mode at `http://localhost:5000`.  You'll see output in your terminal.

## API Endpoints

Here are the pre-configured API endpoints:

*   **Health Check:** `GET /api/v1/health` - Returns the API status and version.
*   **Hello World:** `GET /api/v1/hello` - Returns a simple "Hello, World!" message.

## Adding Your Own Endpoints

To add your own API endpoints, follow these steps:

1.  **Create a Resource:** In `app/api/v1/routes.py`, create a new resource class that inherits from `flask_restful.Resource`.

    \`\`\`python
    from flask_restful import Resource
    from app.api.v1 import api

    class MyResource(Resource):
        def get(self):
            # Implement your GET logic here
            return {'message': 'This is my resource!'}, 200

        def post(self):
            # Implement your POST logic here
            data = request.get_json() # Get the data from the request body
            # Do something with the data
            return {'message': 'Resource created!'}, 201
    \`\`\`

2.  **Define Routes:**  Register your resource with the API using `api.add_resource()`.

    \`\`\`python
    api.add_resource(MyResource, '/myresource')
    \`\`\`

    Now you can access your new endpoint at `http://localhost:5000/api/v1/myresource`.

## Configuration

API configuration is managed through environment variables in the `.env` file.

Example:

\`\`\`
SECRET_KEY=your-super-secret-key
API_TITLE=[PROJECT_NAME] API
API_VERSION=v1
RATE_LIMIT=1000
RATE_LIMIT_PERIOD=15
\`\`\`

**Important:**

*   **`SECRET_KEY`**:  This is crucial for security.  Generate a strong, random key (e.g., using `secrets.token_hex(32)` in Python) and *never* commit it to version control.
*   Store all sensitive information (API keys, database passwords, etc.) in environment variables.

## API Versioning

This project uses API versioning through URL prefixes.  The current version is `v1`.  All endpoints are under the `/api/v1/` path.

**How to Add a New API Version (e.g., v2):**

1.  **Create a New Blueprint:** Create a new blueprint for version 2 in `app/api/`. For example, create `app/api/v2/__init__.py` and `app/api/v2/routes.py`.
2.  **Define v2 Routes:** In `app/api/v2/routes.py`, define your v2 API endpoints.
3.  **Register the Blueprint:**  In `app/__init__.py`, register the v2 blueprint with a new URL prefix.

    \`\`\`python
    from app.api.v2 import bp as api_v2
    app.register_blueprint(api_v2, url_prefix='/api/v2')
    \`\`\`

Now you can access the v2 endpoints using URLs like `http://localhost:5000/api/v2/myresource`.

**Client-Side Versioning (Optional):**

Clients can also indicate their desired API version through:

*   **Headers:**  Use the `Accept` header (e.g., `Accept: application/vnd.myapi.v2+json`).
*   **Query Parameters:**  Add a `version` parameter (e.g., `?version=2`).

You'll need to implement logic in your API to handle these client-side versioning methods.

## Deployment

Refer to the general Flaskify documentation for deployment instructions (Heroku, Docker, Railway).  Remember to set the necessary environment variables on your deployment platform.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for details on how to contribute to this project.

## License

MIT License.  See [LICENSE](LICENSE) for more information.

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
echo "Example endpoint: http://localhost:5000/api/v1/hello"  # Add the hello endpoint