```bash
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
    """Decode