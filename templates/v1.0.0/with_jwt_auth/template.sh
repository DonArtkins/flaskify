#!/bin/bash

# Flaskify - JWT Authentication Template Extension
set -e  # Exit on error

echo "Adding JWT authentication..."

# Create auth directory
mkdir -p "app/auth"
touch "app/auth/__init__.py"

# Create JWT implementation
cat > app/auth/jwt.py << EOF
from flask import current_app, request, jsonify
from functools import wraps
import jwt
from datetime import datetime, timedelta
import uuid

def get_token_from_request():
    """Extract JWT token from request headers."""
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        return None
    
    # Check format
    parts = auth_header.split()
    if parts[0].lower() != 'bearer' or len(parts) != 2:
        return None
    
    return parts[1]

def create_access_token(user_id, additional_claims=None):
    """Create a new JWT access token."""
    payload = {
        'sub': str(user_id),  # Subject (user ID)
        'jti': str(uuid.uuid4()),  # JWT ID (unique)
        'iat': datetime.utcnow(),  # Issued at
        'exp': datetime.utcnow() + timedelta(minutes=current_app.config['JWT_ACCESS_TOKEN_EXPIRES']),  # Expiration
    }
    
    # Add any additional claims
    if additional_claims:
        payload.update(additional_claims)
    
    # Create token
    token = jwt.encode(
        payload,
        current_app.config['JWT_SECRET_KEY'],
        algorithm=current_app.config['JWT_ALGORITHM']
    )
    
    return token

def create_refresh_token(user_id):
    """Create a new JWT refresh token."""
    payload = {
        'sub': str(user_id),  # Subject (user ID)
        'jti': str(uuid.uuid4()),  # JWT ID (unique)
        'iat': datetime.utcnow(),  # Issued at
        'exp': datetime.utcnow() + timedelta(days=current_app.config['JWT_REFRESH_TOKEN_EXPIRES']),  # Expiration
        'type': 'refresh'  # Token type
    }
    
    # Create token
    token = jwt.encode(
        payload,
        current_app.config['JWT_SECRET_KEY'],
        algorithm=current_app.config['JWT_ALGORITHM']
    )
    
    return token

def decode_token(token):
    """Decode and validate a JWT token."""
    try:
        payload = jwt.decode(
            token,
            current_app.config['JWT_SECRET_KEY'],
            algorithms=[current_app.config['JWT_ALGORITHM']]
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise ValueError("Token has expired")
    except jwt.InvalidTokenError:
        raise ValueError("Invalid token")

def token_required(f):
    """Decorator to protect routes with JWT token."""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = get_token_from_request()
        
        if not token:
            return {'error': 'Authentication token is missing'}, 401
        
        try:
            payload = decode_token(token)
            # Add user_id to kwargs for the route function
            kwargs['user_id'] = payload['sub']
        except ValueError as e:
            return {'error': str(e)}, 401
        
        return f(*args, **kwargs)
    return decorated

def refresh_token_required(f):
    """Decorator to protect refresh token routes."""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = get_token_from_request()
        
        if not token:
            return {'error': 'Refresh token is missing'}, 401
        
        try:
            payload = decode_token(token)
            
            # Check if it's a refresh token
            if payload.get('type') != 'refresh':
                return {'error': 'Invalid refresh token'}, 401
                
            # Add user_id to kwargs for the route function
            kwargs['user_id'] = payload['sub']
        except ValueError as e:
            return {'error': str(e)}, 401
        
        return f(*args, **kwargs)
    return decorated
EOF

# Create auth model
cat > app/auth/models.py << EOF
from flask import current_app
from werkzeug.security import generate_password_hash, check_password_hash
import uuid
import time

# In-memory user storage for basic template
# In a real application, this would be replaced with a database model
class User:
    """Simple user model for JWT authentication."""
    
    # Class-level storage
    _users = {}
    
    def __init__(self, username, password, role='user'):
        self.id = str(uuid.uuid4())
        self.username = username
        self.password_hash = generate_password_hash(password)
        self.role = role
        self.created_at = time.time()
        
        # Store in class storage
        User._users[self.id] = self
        
    @classmethod
    def get_by_id(cls, user_id):
        """Get a user by ID."""
        return cls._users.get(user_id)
    
    @classmethod
    def get_by_username(cls, username):
        """Get a user by username."""
        for user in cls._users.values():
            if user.username == username:
                return user
        return None
    
    def check_password(self, password):
        """Check if password is correct."""
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        """Convert user to dictionary."""
        return {
            'id': self.id,
            'username': self.username,
            'role': self.role,
            'created_at': self.created_at
        }
    
    @classmethod
    def create_user(cls, username, password, role='user'):
        """Create a new user."""
        if cls.get_by_username(username):
            return None  # Username already exists
        
        return cls(username, password, role)
EOF

# Create auth routes
cat > app/api/v1/auth_routes.py << EOF
from flask import request, jsonify, current_app
from flask_restful import Resource
from app.api.v1 import api
from app.utils.helpers import rate_limit
from app.auth.jwt import create_access_token, create_refresh_token, token_required, refresh_token_required
from app.auth.models import User

class Register(Resource):
    @rate_limit
    def post(self):
        """Register a new user."""
        data = request.get_json()
        
        if not data or 'username' not in data or 'password' not in data:
            return {'error': 'Missing username or password'}, 400
        
        username = data['username']
        password = data['password']
        
        # Check if username already exists
        if User.get_by_username(username):
            return {'error': 'Username already exists'}, 409
        
        # Create new user
        user = User.create_user(username, password)
        
        return {
            'message': 'User registered successfully',
            'user': user.to_dict()
        }, 201

class Login(Resource):
    @rate_limit
    def post(self):
        """Login and get access token."""
        data = request.get_json()
        
        if not data or 'username' not in data or 'password' not in data:
            return {'error': 'Missing username or password'}, 400
        
        username = data['username']
        password = data['password']
        
        # Find user
        user = User.get_by_username(username)
        if not user or not user.check_password(password):
            return {'error': 'Invalid username or password'}, 401
        
        # Create tokens
        access_token = create_access_token(user.id, {'role': user.role})
        refresh_token = create_refresh_token(user.id)
        
        return {
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': user.to_dict()
        }, 200

class RefreshToken(Resource):
    @refresh_token_required
    def post(self, user_id):
        """Refresh access token using refresh token."""
        # Find user
        user = User.get_by_id(user_id)
        if not user:
            return {'error': 'User not found'}, 404
        
        # Create new access token
        access_token = create_access_token(user.id, {'role': user.role})
        
        return {
            'access_token': access_token
        }, 200

class ProtectedResource(Resource):
    @token_required
    def get(self, user_id):
        """Example protected resource."""
        user = User.get_by_id(user_id)
        if not user:
            return {'error': 'User not found'}, 404
        
        return {
            'message': f'Hello, {user.username}! This is a protected resource.',
            'user': user.to_dict()
        }, 200

# Register routes
api.add_resource(Register, '/auth/register')
api.add_resource(Login, '/auth/login')
api.add_resource(RefreshToken, '/auth/refresh')
api.add_resource(ProtectedResource, '/auth/protected')
EOF

# Update app/__init__.py to include JWT config
cat > app/__init__.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "from flask import Flask",
      "content": "from flask import Flask\nfrom datetime import timedelta"
    }
  ]
}
EOF

# Update config.py to include JWT settings
cat > app/config/config.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "class Config:",
      "content": "class Config:\n    # JWT Configuration\n    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', SECRET_KEY)\n    JWT_ALGORITHM = os.getenv('JWT_ALGORITHM', 'HS256')\n    JWT_ACCESS_TOKEN_EXPIRES = int(os.getenv('JWT_ACCESS_TOKEN_EXPIRES', 15))  # minutes\n    JWT_REFRESH_TOKEN_EXPIRES = int(os.getenv('JWT_REFRESH_TOKEN_EXPIRES', 30))  # days"
    }
  ]
}
EOF

# Update .env to include JWT settings
cat > .env.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# JWT Configuration\nJWT_SECRET_KEY=\nJWT_ALGORITHM=HS256\nJWT_ACCESS_TOKEN_EXPIRES=15\nJWT_REFRESH_TOKEN_EXPIRES=30\n"
    }
  ]
}
EOF

# Update requirements.txt to include JWT library
cat > requirements.txt.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# JWT Authentication\nPyJWT==2.8.0\n"
    }
  ]
}
EOF

# Update routes.py to import the auth routes
cat > app/api/v1/routes.py.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# Import auth routes\nfrom app.api.v1.auth_routes import *\n"
    }
  ]
}
EOF

# Update README to include JWT authentication info
cat > README.md.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "## Features",
      "content": "## Features\n\n- 🚄 High-performance REST API setup\n- 🔒 Built-in rate limiting\n- 🔐 JWT Authentication\n- 🌐 CORS enabled\n- 📝 Clear project structure"
    },
    {
      "type": "append",
      "content": "\n## JWT Authentication\n\nThis API includes JWT authentication with the following endpoints:\n\n- `POST /api/v1/auth/register`: Register a new user\n- `POST /api/v1/auth/login`: Login and get access token\n- `POST /api/v1/auth/refresh`: Refresh access token\n- `GET /api/v1/auth/protected`: Example protected resource\n\nExample login request:\n\n```json\n{\n  \"username\": \"user\",\n  \"password\": \"password\"\n}\n```\n\nTo access protected routes, add the Authorization header:\n\n```\nAuthorization: Bearer <access_token>\n```\n"
    }
  ]
}
EOF

echo "JWT authentication added successfully"