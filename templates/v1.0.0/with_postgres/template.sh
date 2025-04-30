```bash
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
            db.session.rollback()
            raise e
    
    def delete(self):
        """Delete the current instance."""
        try:
            db.session.delete(self)
            db.session.commit()
            return True
        except SQLAlchemyError as e:
            db.session.rollback()
            raise e
    
    @classmethod
    def get_all(cls, **kwargs):
        """Get all records matching the given criteria."""
        return cls.query.filter_by(**kwargs).all()
    
    @classmethod
    def get_by_id(cls, id):
        """Get a record by ID."""
        return cls.query.get(id)
    
    @classmethod
    def get_first(cls, **kwargs):
        """Get the first record matching the given criteria."""
        return cls.query.filter_by(**kwargs).first()

# Example model
class User(db.Model, Base):
    """Example User model."""
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    
    def __repr__(self):
        return f'<User {self.username}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
EOF

# Update app/__init__.py to include PostgreSQL
cat > app/__init__.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "from flask import Flask",
      "content": "from flask import Flask\nfrom app.models.postgres_model import db"
    },
    {
      "type": "replace",
      "target": "# Initialize extensions\n    CORS(app)",
      "content": "# Initialize extensions\n    CORS(app)\n    db.init_app(app)\n    \n    # Create database tables if they don't exist\n    with app.app_context():\n        db.create_all()"
    }
  ]
}
EOF

# Update config.py to include PostgreSQL settings
cat > app/config/config.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "class Config:",
      "content": "class Config:\n    # PostgreSQL Configuration\n    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'postgresql://postgres:postgres@localhost/{{ PROJECT_NAME }}')\n    SQLALCHEMY_TRACK_MODIFICATIONS = False"
    }
  ]
}
EOF

# Update .env to include PostgreSQL settings
cat > .env.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# PostgreSQL Configuration\nDATABASE_URL=postgresql://postgres:postgres@localhost/{{ PROJECT_NAME }}\n"
    }
  ]
}
EOF

# Update requirements.txt to include PostgreSQL drivers
cat > requirements.txt.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# PostgreSQL\nFlask-SQLAlchemy==3.1.1\npsycopg2-binary==2.9.9\nalembic==1.13.1\n"
    }
  ]
}
EOF

# Create a sample PostgreSQL API endpoint
cat > app/api/v1/postgres_routes.py << EOF
from flask import request, jsonify
from flask_restful import Resource
from app.api.v1 import api
from app.utils.helpers import rate_limit
from app.models.postgres_model import User
from sqlalchemy.exc import SQLAlchemyError

class UserListResource(Resource):
    @rate_limit
    def get(self):
        """Get all users."""
        try:
            users = User.get_all()
            return {'users': [user.to_dict() for user in users]}, 200
        except SQLAlchemyError as e:
            return {'error': str(e)}, 500
    
    @rate_limit
    def post(self):
        """Create a new user."""
        try:
            data = request.get_json()
            if not data:
                return {'error': 'No data provided'}, 400
                
            required_fields = ['username', 'email']
            for field in required_fields:
                if field not in data:
                    return {'error': f'Missing required field: {field}'}, 400
            
            # Check if user already exists
            if User.get_first(username=data['username']):
                return {'error': 'Username already exists'}, 409
                
            if User.get_first(email=data['email']):
                return {'error': 'Email already exists'}, 409
            
            # Create user
            user = User.create(**data)
            
            return {'user': user.to_dict()}, 201
        except SQLAlchemyError as e:
            return {'error': str(e)}, 500

class UserResource(Resource):
    @rate_limit
    def get(self, user_id):
        """Get a specific user."""
        try:
            user = User.get_by_id(user_id)
            if not user:
                return {'error': 'User not found'}, 404
                
            return {'user': user.to_dict()}, 200
        except SQLAlchemyError as e:
            return {'error': str(e)}, 500
    
    @rate_limit
    def put(self, user_id):
        """Update a specific user."""
        try:
            user = User.get_by_id(user_id)
            if not user:
                return {'error': 'User not found'}, 404
                
            data = request.get_json()
            if not data:
                return {'error': 'No data provided'}, 400
            
            # Update user fields
            for key, value in data.items():
                if hasattr(user, key):
                    setattr(user, key, value)
            
            user.save()
            
            return {'user': user.to_dict()}, 200
        except SQLAlchemyError as e:
            return {'error': str(e)}, 500
    
    @rate_limit
    def delete(self, user_id):
        """Delete a specific user."""
        try:
            user = User.get_by_id(user_id)
            if not user:
                return {'error': 'User not found'}, 404
                
            user.delete()
            
            return {'message': 'User deleted successfully'}, 200
        except SQLAlchemyError as e:
            return {'error': str(e)}, 500

# Register routes
api.add_resource(UserListResource, '/users')
api.add_resource(UserResource, '/users/<int:user_id>')
EOF

# Update routes.py to import the PostgreSQL routes
cat > app/api/v1/routes.py.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# Import PostgreSQL routes\nfrom app.api.v1.postgres_routes import *\n"
    }
  ]
}
EOF

# Create migrations directory for Alembic
mkdir -p "migrations"

# Add Alembic configuration
cat > alembic.ini << EOF
# A generic, single database configuration.

[alembic]
# path to migration scripts
script_location = migrations

# template used to generate migration files
# file_template = %%(rev)s_%%(slug)s

# timezone to use when rendering the date
# within the migration file as well as the filename.
# string value is passed to dateutil.tz.gettz()
# leave blank for localtime
# timezone =

# max length of characters to apply to the
# "slug" field
# truncate_slug_length = 40

# set to 'true' to run the environment during
# the 'revision' command, regardless of autogenerate
# revision_environment = false

# set to 'true' to allow .pyc and .pyo files without
# a source .py file to be detected as revisions in the
# versions/ directory
# sourceless = false

# version location specification; this defaults
# to alembic/versions.  When using multiple version
# directories, initial revisions must be specified with --version-path
# version_locations = %(here)s/bar %(here)s/bat alembic/versions

# the output encoding used when revision files
# are written from script.py.mako
# output_encoding = utf-8

sqlalchemy.url = postgresql://postgres:postgres@localhost/{{ PROJECT_NAME }}

[post_write_hooks]
# post_write_hooks defines scripts or Python functions that are run
# on newly generated revision scripts.  See the documentation for further
# detail and examples

# format using "black" - use the console_scripts runner, against the "black" entrypoint
# hooks = black
# black.type = console_scripts
# black.entrypoint = black
# black.options = -l 79 REVISION_SCRIPT_FILENAME

# Logging configuration
[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
EOF

mkdir -p "migrations/versions"

# Create migrations environment.py
cat > migrations/env.py << EOF
from logging.config import fileConfig

from sqlalchemy import engine_from_config
from sqlalchemy import pool

from alembic import context

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Interpret the config file for Python logging.
# This line sets up loggers basically.
fileConfig(config.config_file_name)

# add your model's MetaData object here
# for 'autogenerate' support
# from myapp import mymodel
# target_metadata = mymodel.Base.metadata
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from app.models.postgres_model import db
target_metadata = db.metadata

# other values from the config, defined by the needs of env.py,
# can be acquired:
# my_important_option = config.get_main_option("my_important_option")
# ... etc.


def run_migrations_offline():
    """Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well.  By skipping the Engine creation
    we don't even need a DBAPI to be available.

    Calls to context.execute() here emit the given string to the
    script output.

    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online():
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine
    and associate a connection with the context.

    """
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
EOF

# Create script.py.mako
cat > migrations/script.py.mako << EOF
"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""
from alembic import op
import sqlalchemy as sa
${imports if imports else ""}

# revision identifiers, used by Alembic.
revision = ${repr(up_revision)}
down_revision = ${repr(down_revision)}
branch_labels = ${repr(branch_labels)}
depends_on = ${repr(depends_on)}


def upgrade():
    ${upgrades if upgrades else "pass"}


def downgrade():
    ${downgrades if downgrades else "pass"}
EOF

# Update README to include PostgreSQL info
cat > README.md.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "## Features",
      "content": "## Features\n\n- 🚄 High-performance REST API setup\n- 🔒 Built-in rate limiting\n- 🌐 CORS enabled\n- 📝 Clear project structure\n- 🐘 PostgreSQL integration with SQLAlchemy"
    },
    {
      "type": "append",
      "content": "\n## PostgreSQL Integration\n\nThis API includes PostgreSQL integration with the following endpoints:\n\n- `GET /api/v1/users`: Get all users\n- `POST /api/v1/users`: Create a new user\n- `GET /api/v1/users/<id>`: Get a specific user\n- `PUT /api/v1/users/<id>`: Update a specific user\n- `DELETE /api/v1/users/<id>`: Delete a specific user\n\nDatabase migration is handled using Alembic:\n\n```bash\n# Create a new migration\npython -m alembic revision --autogenerate -m \"Description\"\n\n# Run migrations\npython -m alembic upgrade head\n```\n\nConfigure PostgreSQL connection in the `.env` file.\n"
    }
  ]
}
EOF

echo "PostgreSQL integration added successfully"
```