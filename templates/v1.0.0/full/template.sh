#!/bin/bash

# Flaskify - Full Template
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

echo "Creating full-featured Flask API project..."

# Start with basic template
source templates/v1.0.0/basic/template.sh || error_exit "Failed to create basic template"
success_message "Basic template created successfully"

# Add JWT authentication
source templates/v1.0.0/with_jwt_auth/template.sh || error_exit "Failed to add JWT authentication"
success_message "JWT authentication added successfully"

# Add PostgreSQL integration
source templates/v1.0.0/with_postgres/template.sh || error_exit "Failed to add PostgreSQL integration"
success_message "PostgreSQL integration added successfully"

# Add MongoDB integration
source templates/v1.0.0/with_mongodb/template.sh || error_exit "Failed to add MongoDB integration"
success_message "MongoDB integration added successfully"

# Add ML model support
source templates/v1.0.0/with_ml/template.sh || error_exit "Failed to add ML model support"
success_message "ML model support added successfully"

# Connect JWT with PostgreSQL
cat > app/auth/postgres_models.py << EOF
from app.models.postgres_model import db, Base
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

class PostgresUser(db.Model, Base):
    """PostgreSQL user model for JWT authentication."""
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default='user')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<User {self.username}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'role': self.role,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
    
    def set_password(self, password):
        """Set password hash."""
        self.password_hash = generate_password_hash(password)
        return self
    
    def check_password(self, password):
        """Check if password is correct."""
        return check_password_hash(self.password_hash, password)
    
    @classmethod
    def create_user(cls, username, email, password, role='user'):
        """Create a new user."""
        user = cls(username=username, email=email, role=role)
        user.set_password(password)
        return user.save()
    
    @classmethod
    def get_by_username(cls, username):
        """Get a user by username."""
        return cls.query.filter_by(username=username).first()
    
    @classmethod
    def get_by_email(cls, email):
        """Get a user by email."""
        return cls.query.filter_by(email=email).first()
EOF

# Connect JWT with MongoDB
cat > app/auth/mongo_models.py << EOF
from flask import current_app
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import uuid

class MongoUser:
    """MongoDB user model for JWT authentication."""
    
    @classmethod
    def create_user(cls, username, email, password, role='user'):
        """Create a new user."""
        user = {
            'username': username,
            'email': email,
            'password_hash': generate_password_hash(password),
            'role': role,
            'created_at': datetime.utcnow().isoformat()
        }
        
        user_id = current_app.mongo.insert_one('users', user)
        return user_id
    
    @classmethod
    def get_by_id(cls, user_id):
        """Get a user by ID."""
        return current_app.mongo.find_one('users', {'_id': user_id})
    
    @classmethod
    def get_by_username(cls, username):
        """Get a user by username."""
        return current_app.mongo.find_one('users', {'username': username})
    
    @classmethod
    def get_by_email(cls, email):
        """Get a user by email."""
        return current_app.mongo.find_one('users', {'email': email})
    
    @staticmethod
    def check_password(user, password):
        """Check if password is correct."""
        return check_password_hash(user['password_hash'], password)
    
    @classmethod
    def update_user(cls, user_id, update_data):
        """Update a user."""
        return current_app.mongo.update_one('users', {'_id': user_id}, update_data)
    
    @classmethod
    def delete_user(cls, user_id):
        """Delete a user."""
        return current_app.mongo.delete_one('users', {'_id': user_id})
EOF

# Enhance auth routes to support both DB types
cat > app/api/v1/auth_routes.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "from app.auth.models import User",
      "content": "from app.auth.models import User\nfrom app.auth.postgres_models import PostgresUser\nfrom app.auth.mongo_models import MongoUser"
    },
    {
      "type": "append",
      "content": "\nclass DatabaseAuthBase(Resource):\n    \"\"\"Base class for database authentication.\"\"\"\n    \n    def get_db_type(self):\n        \"\"\"Get the database type from request or config.\"\"\"\n        # Try to get from query parameter first\n        db_type = request.args.get('db_type') or request.json.get('db_type')\n        # Fall back to env variable/config\n        if not db_type:\n            db_type = current_app.config.get('DATABASE_TYPE', 'memory')\n        return db_type.lower()\n    \n    def get_user_model(self):\n        \"\"\"Get the appropriate user model based on database type.\"\"\"\n        db_type = self.get_db_type()\n        \n        if db_type == 'postgres':\n            return PostgresUser\n        elif db_type == 'mongodb':\n            return MongoUser\n        else:  # default to memory\n            return User\n\nclass DBRegister(DatabaseAuthBase):\n    @rate_limit\n    def post(self):\n        \"\"\"Register a new user in the selected database.\"\"\"\n        data = request.get_json()\n        \n        if not data or 'username' not in data or 'password' not in data or 'email' not in data:\n            return {'error': 'Missing required fields'}, 400\n        \n        username = data['username']\n        password = data['password']\n        email = data['email']\n        role = data.get('role', 'user')\n        \n        user_model = self.get_user_model()\n        db_type = self.get_db_type()\n        \n        # Check if username already exists\n        existing_user = user_model.get_by_username(username)\n        if existing_user:\n            return {'error': 'Username already exists'}, 409\n        \n        # Create new user based on database type\n        if db_type == 'postgres':\n            user = user_model.create_user(username, email, password, role)\n            return {\n                'message': 'User registered successfully in PostgreSQL',\n                'user': user.to_dict()\n            }, 201\n        elif db_type == 'mongodb':\n            user_id = user_model.create_user(username, email, password, role)\n            return {\n                'message': 'User registered successfully in MongoDB',\n                'user_id': user_id\n            }, 201\n        else:  # memory\n            user = user_model.create_user(username, password, role)\n            return {\n                'message': 'User registered successfully in memory',\n                'user': user.to_dict()\n            }, 201\n\nclass DBLogin(DatabaseAuthBase):\n    @rate_limit\n    def post(self):\n        \"\"\"Login using the selected database.\"\"\"\n        data = request.get_json()\n        \n        if not data or 'username' not in data or 'password' not in data:\n            return {'error': 'Missing username or password'}, 400\n        \n        username = data['username']\n        password = data['password']\n        \n        user_model = self.get_user_model()\n        db_type = self.get_db_type()\n        \n        # Find user based on database type\n        if db_type == 'postgres':\n            user = user_model.get_by_username(username)\n            if not user or not user.check_password(password):\n                return {'error': 'Invalid username or password'}, 401\n                \n            # Create tokens\n            access_token = create_access_token(user.id, {'role': user.role})\n            refresh_token = create_refresh_token(user.id)\n            \n            return {\n                'access_token': access_token,\n                'refresh_token': refresh_token,\n                'user': user.to_dict(),\n                'db_type': 'postgres'\n            }, 200\n        elif db_type == 'mongodb':\n            user = user_model.get_by_username(username)\n            if not user or not user_model.check_password(user, password):\n                return {'error': 'Invalid username or password'}, 401\n                \n            # Create tokens\n            access_token = create_access_token(str(user['_id']), {'role': user.get('role', 'user')})\n            refresh_token = create_refresh_token(str(user['_id']))\n            \n            # Remove password hash from response\n            user.pop('password_hash', None)\n            \n            return {\n                'access_token': access_token,\n                'refresh_token': refresh_token,\n                'user': user,\n                'db_type': 'mongodb'\n            }, 200\n        else:  # memory\n            user = user_model.get_by_username(username)\n            if not user or not user.check_password(password):\n                return {'error': 'Invalid username or password'}, 401\n            \n            # Create tokens\n            access_token = create_access_token(user.id, {'role': user.role})\n            refresh_token = create_refresh_token(user.id)\n            \n            return {\n                'access_token': access_token,\n                'refresh_token': refresh_token,\n                'user': user.to_dict(),\n                'db_type': 'memory'\n            }, 200\n\n# Register database-specific routes\napi.add_resource(DBRegister, '/auth/db/register')\napi.add_resource(DBLogin, '/auth/db/login')"
    }
  ]
}
EOF

# Update config.py to add database selection
cat > app/config/config.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "class Config:",
      "content": "class Config:\n    # Database type (memory, postgres, mongodb)\n    DATABASE_TYPE = os.getenv('DATABASE_TYPE', 'memory')"
    }
  ]
}
EOF

# Update .env to add database selection
cat > .env.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# Database Selection (memory, postgres, mongodb)\nDATABASE_TYPE=memory\n"
    }
  ]
}
EOF

# Update README to include full template info
cat > README.md.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "## Features",
      "content": "## Features\n\n- 🚄 High-performance REST API setup\n- 🔒 Built-in rate limiting\n- 🔐 JWT Authentication\n- 🌐 CORS enabled\n- 📝 Clear project structure\n- 🐘 PostgreSQL integration with SQLAlchemy\n- 🍃 MongoDB integration\n- 🤖 Machine Learning model support\n- 🔄 Multiple database support"
    },
    {
      "type": "append",
      "content": "\n## Full Template Features\n\nThis full-featured template includes everything you need for a production-ready API:\n\n- **Authentication**: JWT-based auth with refresh tokens\n- **Database**: Choose between PostgreSQL, MongoDB, or in-memory storage\n- **ML Support**: Built-in machine learning model handling\n- **Migrations**: Database migrations with Alembic\n- **API Best Practices**: Rate limiting, CORS, proper error handling\n\n### Database Selection\n\nYou can configure which database to use by setting the `DATABASE_TYPE` environment variable:\n\n```bash\n# In .env file\nDATABASE_TYPE=postgres  # Options: memory, postgres, mongodb\n```\n\nOr when making auth requests, specify the database in the request:\n\n```json\n{\n  \"username\": \"user\",\n  \"password\": \"password\",\n  \"email\": \"user@example.com\",\n  \"db_type\": \"postgres\"  # Options: memory, postgres, mongodb\n}\n```\n\n### Combined Auth Endpoints\n\n- Standard endpoints: `/api/v1/auth/register`, `/api/v1/auth/login` (in-memory)\n- Database-specific endpoints: `/api/v1/auth/db/register`, `/api/v1/auth/db/login`\n\n### Multiple Database Support\n\nThis template allows you to use multiple database types simultaneously, making it perfect for microservices or transitioning between database technologies.\n"
    }
  ]
}
EOF

# Create a helper script to choose database
cat > scripts/set_database.sh << EOF
#!/bin/bash

# Simple script to set the default database
set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check args
if [ \$# -ne 1 ]; then
    echo "Usage: \$0 <database_type>"
    echo "Available types: memory, postgres, mongodb"
    exit 1
fi

DB_TYPE=\$1

# Validate database type
if [[ ! "\$DB_TYPE" =~ ^(memory|postgres|mongodb)$ ]]; then
    echo "Invalid database type. Available types: memory, postgres, mongodb"
    exit 1
fi

# Update .env file
sed -i'.bak' "s/DATABASE_TYPE=.*/DATABASE_TYPE=\$DB_TYPE/" .env

echo -e "\${GREEN}Database set to \${YELLOW}\$DB_TYPE\${NC}"

case \$DB_TYPE in
    postgres)
        echo -e "\${YELLOW}Don't forget to set up PostgreSQL and run migrations!\${NC}"
        echo "python -m alembic upgrade head"
        ;;
    mongodb)
        echo -e "\${YELLOW}Don't forget to configure MongoDB connection in .env!\${NC}"
        echo "MONGO_URI=mongodb://localhost:27017"
        echo "MONGO_DB_NAME=your_db_name"
        ;;
esac

echo -e "\${GREEN}Configuration updated successfully\${NC}"
EOF
chmod +x scripts/set_database.sh

# Create a health check script
mkdir -p scripts
cat > scripts/health_check.sh << EOF
#!/bin/bash

# Health check script for the API
set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get API URL from argument or use default
API_URL=\${1:-"http://localhost:5000"}
HEALTH_ENDPOINT="\$API_URL/api/v1/health"

echo -e "\${YELLOW}Checking API health at \$HEALTH_ENDPOINT...\${NC}"

# Make request
response=\$(curl -s -o response.json -w "%{http_code}" \$HEALTH_ENDPOINT)

if [ \$response -eq 200 ]; then
    echo -e "\${GREEN}API is healthy!\${NC}"
    cat response.json | python -m json.tool
else
    echo -e "\${RED}API is not responding properly. Status code: \$response\${NC}"
    if [ -f response.json ]; then
        cat response.json | python -m json.tool
    fi
fi

# Clean up
rm -f response.json
EOF
chmod +x scripts/health_check.sh

# Create script directory
mkdir -p scripts

# Create setup script
cat > scripts/setup_project.sh << EOF
#!/bin/bash

# Setup script for the Flask API project
set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "\${YELLOW}Setting up the Flask API project...\${NC}"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo -e "\${YELLOW}Creating virtual environment...\${NC}"
    python -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install requirements
echo -e "\${YELLOW}Installing dependencies...\${NC}"
pip install -r requirements.txt

# Generate a random secret key
SECRET_KEY=\$(python -c "import secrets; print(secrets.token_hex(32))")
JWT_SECRET_KEY=\$(python -c "import secrets; print(secrets.token_hex(32))")

# Update .env file with secret keys
sed -i'.bak' "s/SECRET_KEY=.*/SECRET_KEY=\$SECRET_KEY/" .env
sed -i'.bak' "s/JWT_SECRET_KEY=.*/JWT_SECRET_KEY=\$JWT_SECRET_KEY/" .env

# Create databases based on configuration
DB_TYPE=\$(grep -oP 'DATABASE_TYPE=\K.*' .env)

echo -e "\${YELLOW}Setting up \$DB_TYPE database...\${NC}"

case \$DB_TYPE in
    postgres)
        if command -v psql &> /dev/null; then
            # Extract database name from DATABASE_URL
            DB_NAME=\$(grep -oP 'DATABASE_URL=.*?/\K[^?]*' .env)
            
            # Check if database exists
            if ! psql -lqt | cut -d \| -f 1 | grep -qw \$DB_NAME; then
                echo -e "\${YELLOW}Creating PostgreSQL database \$DB_NAME...\${NC}"
                createdb \$DB_NAME || echo -e "\${RED}Failed to create database. You may need to create it manually.\${NC}"
            else
                echo -e "\${GREEN}PostgreSQL database \$DB_NAME already exists.\${NC}"
            fi
            
            # Run migrations
            echo -e "\${YELLOW}Running database migrations...\${NC}"
            python -m alembic upgrade head
        else
            echo -e "\${RED}PostgreSQL client (psql) not found. Please install PostgreSQL or create the database manually.\${NC}"
        fi
        ;;
    mongodb)
        echo -e "\${YELLOW}Please ensure MongoDB is running at the URI specified in .env\${NC}"
        echo -e "\${YELLOW}No additional setup needed for MongoDB.\${NC}"
        ;;
    *)
        echo -e "\${GREEN}Using in-memory database. No additional setup needed.\${NC}"
        ;;
esac

echo -e "\${GREEN}Setup completed successfully!\${NC}"
echo -e "\${YELLOW}Run the application with: python run.py\${NC}"
EOF
chmod +x scripts/setup_project.sh

# Create project management dashboard tools
cat > scripts/project_dashboard.sh << EOF
#!/bin/bash

# Flask API Project Management Dashboard
set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if dialog is installed
if ! command -v dialog &> /dev/null; then
    echo -e "\${RED}Dialog not found. Please install dialog to use this dashboard.\${NC}"
    echo "On Ubuntu/Debian: sudo apt-get install dialog"
    echo "On CentOS/RHEL: sudo yum install dialog"
    echo "On macOS: brew install dialog"
    exit 1
fi

# Get project information
PROJECT_NAME=\$(grep -oP 'name="\K[^"]*' setup.py || echo "Flask API")
VERSION=\$(grep -oP 'version="\K[^"]*' setup.py || echo "0.1.0")
DB_TYPE=\$(grep -oP 'DATABASE_TYPE=\K.*' .env || echo "memory")

# Function to display project status
show_status() {
    clear
    echo -e "\${BLUE}======================================\${NC}"
    echo -e "\${BLUE}      \$PROJECT_NAME Status (\$VERSION)     \${NC}"
    echo -e "\${BLUE}======================================\${NC}"
    echo
    echo -e "\${YELLOW}Database Type:\${NC} \$DB_TYPE"
    
    # Check if virtual environment is activated
    if [[ "\$VIRTUAL_ENV" != "" ]]; then
        echo -e "\${YELLOW}Virtual Environment:\${NC} \${GREEN}Activated\${NC} (\$(basename \$VIRTUAL_ENV))"
    else
        echo -e "\${YELLOW}Virtual Environment:\${NC} \${RED}Not Activated\${NC}"
    fi
    
    # Check dependencies
    if [[ -f requirements.txt ]]; then
        echo -e "\${YELLOW}Dependencies:\${NC} \$(wc -l < requirements.txt) packages required"
    else
        echo -e "\${YELLOW}Dependencies:\${NC} \${RED}requirements.txt not found\${NC}"
    fi
    
    # Check for .env file
    if [[ -f .env ]]; then
        echo -e "\${YELLOW}Configuration:\${NC} \${GREEN}.env file found\${NC}"
    else
        echo -e "\${YELLOW}Configuration:\${NC} \${RED}.env file not found\${NC}"
    fi
    
    # Database-specific checks
    case \$DB_TYPE in
        postgres)
            # Check PostgreSQL connection
            if grep -q "DATABASE_URL" .env; then
                echo -e "\${YELLOW}PostgreSQL:\${NC} \${GREEN}Configured\${NC}"
                
                # Check for migrations
                if [[ -d migrations/versions ]]; then
                    MIGRATION_COUNT=\$(ls -1 migrations/versions | wc -l)
                    echo -e "\${YELLOW}Migrations:\${NC} \$MIGRATION_COUNT migration(s) available"
                else
                    echo -e "\${YELLOW}Migrations:\${NC} \${RED}No migrations found\${NC}"
                fi
            else
                echo -e "\${YELLOW}PostgreSQL:\${NC} \${RED}Not configured\${NC}"
            fi
            ;;
        mongodb)
            # Check MongoDB connection
            if grep -q "MONGO_URI" .env; then
                echo -e "\${YELLOW}MongoDB:\${NC} \${GREEN}Configured\${NC}"
            else
                echo -e "\${YELLOW}MongoDB:\${NC} \${RED}Not configured\${NC}"
            fi
            ;;
        *)
            echo -e "\${YELLOW}Database:\${NC} Using in-memory storage"
            ;;
    esac
    
    # Check for running server
    PID=\$(pgrep -f "python run.py" || echo "")
    if [[ "\$PID" != "" ]]; then
        echo -e "\${YELLOW}Server Status:\${NC} \${GREEN}Running\${NC} (PID: \$PID)"
    else
        echo -e "\${YELLOW}Server Status:\${NC} \${RED}Not Running\${NC}"
    fi
    
    echo
    echo -e "Press any key to return to the menu..."
    read -n 1
}

# Function to run tests
run_tests() {
    clear
    echo -e "\${BLUE}Running tests...\${NC}"
    
    if [[ -d "tests" ]]; then
        python -m pytest tests -v
    else
        echo -e "\${RED}Test directory not found.\${NC}"
    fi
    
    echo
    echo -e "Press any key to return to the menu..."
    read -n 1
}

# Main dashboard loop
while true; do
    OPTION=\$(dialog --clear --backtitle "Flask API Project Dashboard" \
        --title "[ \$PROJECT_NAME v\$VERSION ]" \
        --menu "Choose an option:" 15 60 8 \
        1 "View Project Status" \
        2 "Start Development Server" \
        3 "Setup Project" \
        4 "Change Database Type" \
        5 "Run Migrations" \
        6 "Run Tests" \
        7 "Check API Health" \
        8 "Exit" \
        2>&1 >/dev/tty)
    
    case \$OPTION in
        1)
            show_status
            ;;
        2)
            clear
            echo -e "\${BLUE}Starting development server...\${NC}"
            python run.py
            echo -e "Press any key to return to the menu..."
            read -n 1
            ;;
        3)
            clear
            echo -e "\${BLUE}Setting up project...\${NC}"
            ./scripts/setup_project.sh
            echo -e "Press any key to return to the menu..."
            read -n 1
            ;;
        4)
            DB_CHOICE=\$(dialog --clear --backtitle "Flask API Project Dashboard" \
                --title "[ Change Database Type ]" \
                --menu "Select database type:" 12 50 3 \
                1 "In-Memory (default)" \
                2 "PostgreSQL" \
                3 "MongoDB" \
                2>&1 >/dev/tty)
            
            case \$DB_CHOICE in
                1) ./scripts/set_database.sh memory ;;
                2) ./scripts/set_database.sh postgres ;;
                3) ./scripts/set_database.sh mongodb ;;
                *) continue ;;
            esac
            
            # Update DB_TYPE variable
            DB_TYPE=\$(grep -oP 'DATABASE_TYPE=\K.*' .env || echo "memory")
            
            echo -e "Press any key to return to the menu..."
            read -n 1
            ;;
        5)
            clear
            if [[ "\$DB_TYPE" == "postgres" ]]; then
                echo -e "\${BLUE}Running database migrations...\${NC}"
                python -m alembic upgrade head
            else
                echo -e "\${RED}Migrations are only available for PostgreSQL.\${NC}"
            fi
            echo -e "Press any key to return to the menu..."
            read -n 1
            ;;
        6)
            run_tests
            ;;
        7)
            clear
            echo -e "\${BLUE}Checking API health...\${NC}"
            ./scripts/health_check.sh
            echo -e "Press any key to return to the menu..."
            read -n 1
            ;;
        8)
            clear
            echo -e "\${GREEN}Exiting dashboard. Goodbye!\${NC}"
            exit 0
            ;;
        *)
            continue
            ;;
    esac
done
EOF
chmod +x scripts/project_dashboard.sh

# Create deployment guide
cat > docs/deployment_guide.md << EOF
# Deployment Guide

This guide provides instructions for deploying the Flask API to various environments.

## Prerequisites

- Python 3.8+
- PostgreSQL and/or MongoDB (based on your configuration)
- A Unix-like environment (Linux, macOS)

## Preparing for Deployment

1. Update the configuration in \`.env\` file:
   - Set \`FLASK_ENV=production\`
   - Set a strong \`SECRET_KEY\` and \`JWT_SECRET_KEY\`
   - Configure database details

2. Install production dependencies:
   ```bash
   pip install gunicorn
   ```

## Deployment Options

### 1. Traditional Server Deployment

#### Setup with Gunicorn and Nginx

1. Install Gunicorn and Nginx:
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install nginx
   ```

2. Create a systemd service file:
   ```bash
   sudo nano /etc/systemd/system/flaskapi.service
   ```

3. Add the following content:
   ```
   [Unit]
   Description=Flask API Service
   After=network.target

   [Service]
   User=username
   WorkingDirectory=/path/to/your/project
   Environment="PATH=/path/to/your/venv/bin"
   ExecStart=/path/to/your/venv/bin/gunicorn -b 127.0.0.1:8000 -w 4 "run:app"
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

4. Configure Nginx:
   ```bash
   sudo nano /etc/nginx/sites-available/flaskapi
   ```

5. Add the following content:
   ```
   server {
       listen 80;
       server_name your_domain.com;

       location / {
           proxy_pass http://127.0.0.1:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

6. Enable the site and restart services:
   ```bash
   sudo ln -s /etc/nginx/sites-available/flaskapi /etc/nginx/
   ```
# Add security enhancements
cat > app/security/__init__.py << EOF
"""Security module for enhanced application security."""
from flask import current_app, request
import secrets
import re
import hashlib
import base64
from functools import wraps

def initialize_security(app):
    """Initialize security features."""
    app.config.setdefault('SECURITY_ENABLED', True)
    app.config.setdefault('SECURITY_CONTENT_SECURITY_POLICY', True)
    app.config.setdefault('SECURITY_STRICT_TRANSPORT_SECURITY', True)
    
    @app.after_request
    def add_security_headers(response):
        """Add security headers to each response."""
        if app.config['SECURITY_ENABLED']:
            # Security headers
            response.headers['X-Content-Type-Options'] = 'nosniff'
            response.headers['X-Frame-Options'] = 'SAMEORIGIN'
            response.headers['X-XSS-Protection'] = '1; mode=block'
            
            # Content Security Policy
            if app.config['SECURITY_CONTENT_SECURITY_POLICY']:
                response.headers['Content-Security-Policy'] = (
                    "default-src 'self'; "
                    "script-src 'self'; "
                    "style-src 'self'; "
                    "img-src 'self' data:; "
                    "font-src 'self'; "
                    "object-src 'none'; "
                    "connect-src 'self'"
                )
            
            # HSTS
            if app.config['SECURITY_STRICT_TRANSPORT_SECURITY'] and not app.debug:
                response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
                
        return response

# CSRF Protection
def generate_csrf_token():
    """Generate a secure CSRF token."""
    return base64.b64encode(secrets.token_bytes(32)).decode('utf-8')

def verify_csrf_token(token):
    """Verify a CSRF token."""
    if not token or not current_app.csrf_token:
        return False
    
    # Use constant-time comparison to prevent timing attacks
    return secrets.compare_digest(token, current_app.csrf_token)

def csrf_required(f):
    """Decorator to require CSRF token verification."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Only check POST/PUT/DELETE/PATCH requests
        if request.method in ('POST', 'PUT', 'DELETE', 'PATCH'):
            token = request.headers.get('X-CSRF-Token')
            if not verify_csrf_token(token):
                return {'error': 'CSRF token missing or invalid'}, 403
        return f(*args, **kwargs)
    return decorated_function
EOF

# Add monitoring and logging integration
mkdir -p app/monitoring
cat > app/monitoring/__init__.py << EOF
"""Monitoring and logging utilities."""
import logging
import time
from flask import request, g, current_app
import uuid
import json
from functools import wraps

class RequestMonitor:
    """Request monitoring and logging."""

    def __init__(self, app=None):
        self.app = app
        self.logger = logging.getLogger('request_monitor')
        
        if app is not None:
            self.init_app(app)
            
    def init_app(self, app):
        """Initialize with Flask app."""
        app.before_request(self.before_request)
        app.after_request(self.after_request)
        app.teardown_request(self.teardown_request)
        
        # Configure logger
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            '[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
        )
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
        self.logger.setLevel(app.config.get('LOG_LEVEL', logging.INFO))
        
    def before_request(self):
        """Log before processing request."""
        g.start_time = time.time()
        g.request_id = str(uuid.uuid4())
        
        # Log the request
        self.logger.info(
            f"Request started: {g.request_id} - {request.method} {request.path}"
        )
        
    def after_request(self, response):
        """Log after processing request."""
        if hasattr(g, 'start_time'):
            duration = time.time() - g.start_time
            self.logger.info(
                f"Request {g.request_id} completed: {response.status_code} in {duration:.4f}s"
            )
            
            # Add request ID to response headers
            response.headers['X-Request-ID'] = g.request_id
            
            # Log slow requests
            if current_app.config.get('SLOW_REQUEST_THRESHOLD') and \
                    duration > current_app.config.get('SLOW_REQUEST_THRESHOLD'):
                self.logger.warning(
                    f"Slow request detected: {g.request_id} took {duration:.4f}s"
                )
        
        return response
        
    def teardown_request(self, exception=None):
        """Log exceptions during request processing."""
        if exception:
            self.logger.error(
                f"Request {getattr(g, 'request_id', 'unknown')} failed with exception: {str(exception)}"
            )

def log_function_execution(func=None, *, level=logging.INFO):
    """Decorator to log function execution time."""
    def decorator(f):
        @wraps(f)
        def wrapped(*args, **kwargs):
            logger = logging.getLogger(f.__module__)
            start_time = time.time()
            
            try:
                result = f(*args, **kwargs)
                duration = time.time() - start_time
                
                # Log execution
                logger.log(
                    level,
                    f"Function '{f.__name__}' executed in {duration:.4f}s"
                )
                
                return result
            except Exception as e:
                duration = time.time() - start_time
                logger.error(
                    f"Function '{f.__name__}' failed after {duration:.4f}s with error: {str(e)}"
                )
                raise
        
        return wrapped
    
    if func:
        return decorator(func)
    return decorator
EOF

# Update run.py to include monitoring
cat > run.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "from app import create_app",
      "content": "from app import create_app\nfrom app.monitoring import RequestMonitor"
    },
    {
      "type": "append",
      "content": "\n# Initialize monitoring\nrequest_monitor = RequestMonitor(app)"
    }
  ]
}
EOF

# Add API versioning handler
cat > app/utils/versioning.py << EOF
"""API versioning utilities."""
from functools import wraps
from flask import request, current_app, jsonify

def api_version_required(min_version, max_version=None):
    """Decorator to enforce API version requirements."""
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            # Extract version from request
            version = request.headers.get('X-API-Version', current_app.config['API_VERSION'])
            
            # Remove 'v' prefix if present
            if version and version.lower().startswith('v'):
                version = version[1:]
                
            # Convert to float for comparison
            try:
                v_float = float(version)
                min_v_float = float(min_version.lstrip('v'))
                max_v_float = float(max_version.lstrip('v')) if max_version else None
            except ValueError:
                return jsonify({'error': 'Invalid API version format'}), 400
            
            # Check version constraints
            if v_float < min_v_float:
                return jsonify({
                    'error': f'This endpoint requires API version {min_version} or higher',
                    'current_version': version,
                    'required_version': min_version
                }), 400
                
            if max_v_float and v_float > max_v_float:
                return jsonify({
                    'error': f'This endpoint requires API version {max_v_float} or lower',
                    'current_version': version,
                    'required_version': f'<= {max_version}'
                }), 400
                
            return f(*args, **kwargs)
        return wrapper
    return decorator
EOF

# Add example usage of versioning
cat > app/api/v1/routes.py.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\nfrom app.utils.versioning import api_version_required\n\nclass VersionedResource(Resource):\n    @rate_limit\n    @api_version_required('1.0', '1.5')\n    def get(self):\n        \"\"\"Example of versioned endpoint (requires v1.0-v1.5).\"\"\"\n        return {\n            'message': 'This endpoint is available in API versions 1.0 to 1.5',\n            'version': request.headers.get('X-API-Version', current_app.config['API_VERSION'])\n        }\n\n# Register versioned endpoint\napi.add_resource(VersionedResource, '/versioned')"
    }
  ]
}
EOF

# Create API documentation setup
cat > app/api/docs.py << EOF
"""API documentation setup."""
from flask import Blueprint, render_template, current_app
import os
import json
import markdown
import re
from flask_restful import Resource

# Create docs blueprint
docs_bp = Blueprint('docs', __name__)

# Custom renderer for API documentation
class APIDocumentation:
    def __init__(self, app=None):
        self.app = app
        self.endpoints = []
        self.version = 'v1'
        
        if app is not None:
            self.init_app(app)
            
    def init_app(self, app):
        """Initialize with Flask app."""
        self.app = app
        self.version = app.config.get('API_VERSION', 'v1')
        
        # Register docs blueprint
        app.register_blueprint(docs_bp, url_prefix='/api/docs')
        
        # Add URL rule for API docs JSON
        app.add_url_rule(
            f'/api/{self.version}/docs.json',
            endpoint='api_docs_json',
            view_func=self.get_docs_json
        )
        
    def get_docs_json(self):
        """Generate API documentation in JSON format."""
        self.collect_endpoints()
        
        return {
            'api_name': self.app.config.get('API_TITLE', 'Flask API'),
            'version': self.version,
            'endpoints': self.endpoints,
            'base_url': f'/api/{self.version}'
        }
        
    def collect_endpoints(self):
        """Collect API endpoints and documentation."""
        self.endpoints = []
        
        # Iterate through all Flask-RESTful resources
        api_resources = self.app.extensions.get('flask_restful', {}).resources or []
        
        for resource, urls, kwargs in api_resources:
            for url in urls:
                # Only include endpoints in the current API version
                if f'/api/{self.version}/' in url:
                    endpoint_data = self._parse_resource_docs(resource, url)
                    if endpoint_data:
                        self.endpoints.append(endpoint_data)
    
    def _parse_resource_docs(self, resource_cls, url):
        """Parse documentation from a resource class."""
        endpoint = {
            'url': url,
            'methods': [],
            'name': resource_cls.__name__,
            'description': resource_cls.__doc__ or 'No description'
        }
        
        # Check for HTTP methods in the resource
        for method in ['get', 'post', 'put', 'delete', 'patch']:
            if hasattr(resource_cls, method):
                method_func = getattr(resource_cls, method)
                endpoint['methods'].append({
                    'type': method.upper(),
                    'description': method_func.__doc__ or 'No description',
                    'auth_required': self._check_if_auth_required(method_func),
                    'rate_limited': self._check_if_rate_limited(method_func)
                })
                
        # Only include endpoints with methods
        return endpoint if endpoint['methods'] else None
    
    def _check_if_auth_required(self, func):
        """Check if a function requires authentication."""
        # Check if the function is wrapped with login_required
        # This is a simplified check and might not work for all decorators
        return 'jwt_required' in str(func.__code__.co_consts)
    
    def _check_if_rate_limited(self, func):
        """Check if a function is rate limited."""
        # Check if the function is wrapped with rate_limit
        return 'rate_limit' in str(func.__code__.co_consts)

# Routes for documentation
@docs_bp.route('/')
def index():
    """API documentation index page."""
    return f'<h1>API Documentation</h1><p>View the <a href="/api/{current_app.config.get("API_VERSION", "v1")}/docs.json">API docs JSON</a>.</p>'
EOF

# Update app factory to include docs
cat > app/__init__.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "from flask import Flask",
      "content": "from flask import Flask\nfrom app.api.docs import APIDocumentation"
    },
    {
      "type": "append",
      "content": "\n    # Initialize API documentation\n    api_docs = APIDocumentation(app)"
    }
  ]
}
EOF

# Add cache utility
cat > app/utils/cache.py << EOF
"""Caching utilities for the API."""
from functools import wraps
from flask import request, current_app
import time
import hashlib
import json
import threading

class SimpleCache:
    """Simple in-memory cache implementation."""
    
    def __init__(self, default_ttl=300):
        """Initialize cache with default TTL in seconds."""
        self.cache = {}
        self.default_ttl = default_ttl
        self.lock = threading.Lock()
        
    def get(self, key):
        """Get a value from the cache."""
        with self.lock:
            if key not in self.cache:
                return None
                
            value, expiry = self.cache[key]
            
            # Check if expired
            if expiry < time.time():
                del self.cache[key]
                return None
                
            return value
            
    def set(self, key, value, ttl=None):
        """Set a value in the cache with TTL in seconds."""
        if ttl is None:
            ttl = self.default_ttl
            
        with self.lock:
            expiry = time.time() + ttl
            self.cache[key] = (value, expiry)
            
    def delete(self, key):
        """Delete a key from the cache."""
        with self.lock:
            if key in self.cache:
                del self.cache[key]
                
    def clear(self):
        """Clear all cache entries."""
        with self.lock:
            self.cache.clear()
            
# Create global cache instance
cache = SimpleCache()

def cached(ttl=None):
    """Decorator to cache function results."""
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            # Generate cache key
            key_parts = [
                f.__module__,
                f.__name__,
                str(args),
                str(kwargs)
            ]
            
            # For HTTP requests, include method and path
            if request:
                key_parts.extend([
                    request.method,
                    request.path,
                    str(dict(request.args))
                ])
                
            # Create hash from parts
            key = hashlib.md5(json.dumps(key_parts).encode()).hexdigest()
            
            # Try to get from cache
            cached_value = cache.get(key)
            if cached_value is not None:
                return cached_value
                
            # Execute function and cache result
            result = f(*args, **kwargs)
            cache.set(key, result, ttl)
            return result
        
        return wrapper
    
    return decorator
EOF

# Update .env to include the new features
cat > .env.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# Monitoring & Logging\nLOG_LEVEL=INFO\nSLOW_REQUEST_THRESHOLD=1.0  # seconds\n\n# Security\nSECURITY_ENABLED=True\nSECURITY_CONTENT_SECURITY_POLICY=True\nSECURITY_STRICT_TRANSPORT_SECURITY=True\n"
    }
  ]
}
EOF

# Update requirements.txt
cat > requirements.txt.merge << EOF
{
  "operations": [
    {
      "type": "append", 
      "content": "Flask-Limiter==3.3.1\npyjwt==2.8.0\nsqlalchemy==2.0.23\npsycopg2-binary==2.9.9\npymongo==4.6.0\nalembic==1.12.0\npandas==2.0.3\nscikit-learn==1.3.0\njoblib==1.3.2\nnumpy==1.24.3\nmarkdown==3.5\ngunicorn==21.2.0\n"
    }
  ]
}
EOF

# Create a Docker setup
cat > Dockerfile << EOF
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \\
    build-essential \\
    libpq-dev \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=run.py
ENV FLASK_ENV=production

# Expose port
EXPOSE 5000

# Run with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]
EOF

# Create docker-compose setup
cat > docker-compose.yml << EOF
version: '3.8'

services:
  api:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      - postgres
      - mongodb
    env_file:
      - .env
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/flask_api
      - MONGO_URI=mongodb://mongodb:27017/
      - MONGO_DB_NAME=flask_api
    volumes:
      - ./app:/app/app
    restart: unless-stopped

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=flask_api
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  mongodb:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    restart: unless-stopped

volumes:
  postgres_data:
  mongo_data:
EOF

# Create .env.docker file for Docker environment
cat > .env.docker << EOF
# Flask Configuration
FLASK_APP=run.py
FLASK_ENV=production
FLASK_DEBUG=False
FLASK_HOST=0.0.0.0
FLASK_PORT=5000

# API Configuration
API_TITLE=Flask API
API_VERSION=v1
RATE_LIMIT=100
RATE_LIMIT_PERIOD=60

# Database Selection (postgres, mongodb, memory)
DATABASE_TYPE=postgres

# PostgreSQL
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/flask_api

# MongoDB
MONGO_URI=mongodb://mongodb:27017/
MONGO_DB_NAME=flask_api

# Security
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
JWT_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
SECURITY_ENABLED=True

# Monitoring & Logging
LOG_LEVEL=INFO
SLOW_REQUEST_THRESHOLD=1.0  # seconds
EOF

# Create GitHub Actions CI workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << EOF
name: CI

on:
  push:
    branches: [ main, dev ]
  pull_request:
    branches: [ main, dev ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      mongodb:
        image: mongo:6
        ports:
          - 27017:27017
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
        pip install pytest pytest-cov flake8
    
    - name: Lint with flake8
      run: |
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
    
    - name: Test with pytest
      env:
        FLASK_ENV: testing
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
        MONGO_URI: mongodb://localhost:27017/
        MONGO_DB_NAME: test_db
      run: |
        pytest --cov=app tests/
EOF

success_message "Full template created successfully!"
echo "Your API project is ready to use. Check the README.md for details."