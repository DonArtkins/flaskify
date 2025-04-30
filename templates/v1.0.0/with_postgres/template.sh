#!/bin/bash

# Flaskify - PostgreSQL Template Extension
set -e  # Exit on error

echo "Adding PostgreSQL integration..."

# Create models directory
mkdir -p "app/models"
touch "app/models/__init__.py"

# Create PostgreSQL model file
cat > app/models/postgres_model.py << EOF
from flask import current_app
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import SQLAlchemyError
import os

# Initialize SQLAlchemy
db = SQLAlchemy()

class Base:
    """Base model class with common operations."""
    
    @classmethod
    def create(cls, **kwargs):
        """Create a new record."""
        instance = cls(**kwargs)
        return instance.save()
    
    def save(self):
        """Save the current instance."""
        try:
            db.session.add(self)
            db.session.commit()
            return self
        except SQLAlchemyError as e:
            db