#!/bin/bash

# Flaskify - MongoDB Template Extension
set -e  # Exit on error

echo "Adding MongoDB integration..."

# Create models directory
mkdir -p "app/models"
touch "app/models/__init__.py"

# Create MongoDB model file
cat > app/models/mongo_model.py << EOF
from flask import current_app
from pymongo import MongoClient
from bson.objectid import ObjectId
import os

class MongoDB:
    """MongoDB connection and operations class."""
    
    def __init__(self, app=None):
        self.client = None
        self.db = None
        
        if app is not None:
            self.init_app(app)
    
    def init_app(self, app):
        """Initialize MongoDB with the Flask app."""
        mongo_uri = app.config.get('MONGO_URI')
        db_name = app.config.get('MONGO_DB_NAME')
        
        if not mongo_uri or not db_name:
            raise ValueError("MONGO_URI and MONGO_DB_NAME must be set in the Flask app config")
        
        self.client = MongoClient(mongo_uri)
        self.db = self.client[db_name]
        
        # Add MongoDB instance to app
        app.mongo = self
        
        # Register close function
        @app.teardown_appcontext
        def close_mongo_connection(exception):
            if self.client:
                self.client.close()
    
    def get_collection(self, collection_name):
        """Get a MongoDB collection."""
        if not self.db:
            raise RuntimeError("MongoDB not initialized. Call init_app first.")
        return self.db[collection_name]
    
    def insert_one(self, collection_name, document):
        """Insert a document into a collection."""
        collection = self.get_collection(collection_name)
        result = collection.insert_one(document)
        return str(result.inserted_id)
    
    def find_one(self, collection_name, query):
        """Find a document in a collection."""
        collection = self.get_collection(collection_name)
        if '_id' in query and isinstance(query['_id'], str):
            query['_id'] = ObjectId(query['_id'])
        document = collection.find_one(query)
        return document
    
    def find(self, collection_name, query=None, limit=0, skip=0, sort=None):
        """Find documents in a collection."""
        collection = self.get_collection(collection_name)
        if query is None:
            query = {}
        if '_id' in query and isinstance(query['_id'], str):
            query['_id'] = ObjectId(query['_id'])
        
        cursor = collection.find(query)
        
        if skip:
            cursor = cursor.skip(skip)
        if limit:
            cursor = cursor.limit(limit)
        if sort:
            cursor = cursor.sort(sort)
        
        return list(cursor)
    
    def update_one(self, collection_name, query, update):
        """Update a document in a collection."""
        collection = self.get_collection(collection_name)
        if '_id' in query and isinstance(query['_id'], str):
            query['_id'] = ObjectId(query['_id'])
        result = collection.update_one(query, {'$set': update})
        return result.modified_count
    
    def delete_one(self, collection_name, query):
        """Delete a document from a collection."""
        collection = self.get_collection(collection_name)
        if '_id' in query and isinstance(query['_id'], str):
            query['_id'] = ObjectId(query['_id'])
        result = collection.delete_one(query)
        return result.deleted_count
EOF

# Update app/__init__.py to include MongoDB
cat > app/__init__.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "from flask import Flask",
      "content": "from flask import Flask\nfrom app.models.mongo_model import MongoDB"
    },
    {
      "type": "replace",
      "target": "# Initialize extensions\n    CORS(app)",
      "content": "# Initialize extensions\n    CORS(app)\n    mongo = MongoDB(app)"
    }
  ]
}
EOF

# Update config.py to include MongoDB settings
cat > app/config/config.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "class Config:",
      "content": "class Config:\n    # MongoDB Configuration\n    MONGO_URI = os.getenv('MONGO_URI', 'mongodb://localhost:27017')\n    MONGO_DB_NAME = os.getenv('MONGO_DB_NAME', '{{ PROJECT_NAME }}')"
    }
  ]
}
EOF

# Update .env to include MongoDB settings
cat > .env.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# MongoDB Configuration\nMONGO_URI=mongodb://localhost:27017\nMONGO_DB_NAME={{ PROJECT_NAME }}\n"
    }
  ]
}
EOF

# Update requirements.txt to include MongoDB driver
cat > requirements.txt.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# MongoDB\npymongo==4.6.0\n"
    }
  ]
}
EOF

# Create a sample MongoDB API endpoint
cat > app/api/v1/mongo_routes.py << EOF
from flask import request, jsonify
from flask_restful import Resource
from app.api.v1 import api
from app.utils.helpers import rate_limit
from flask import current_app
from bson.json_util import dumps
import json
from bson.objectid import ObjectId

class MongoDBCollection(Resource):
    @rate_limit
    def get(self, collection_name):
        """Get all documents from a collection."""
        try:
            # Get query parameters
            limit = int(request.args.get('limit', 100))
            skip = int(request.args.get('skip', 0))
            
            # Get documents
            documents = current_app.mongo.get_collection(collection_name).find({}, limit=limit, skip=skip)
            
            # Convert ObjectId to string for JSON serialization
            result = json.loads(dumps(list(documents)))
            
            return {
                'result': result,
                'count': len(result)
            }, 200
            
        except Exception as e:
            return {'error': str(e)}, 500

    @rate_limit
    def post(self, collection_name):
        """Create a new document in a collection."""
        try:
            data = request.get_json()
            if not data:
                return {'error': 'No data provided'}, 400
                
            # Insert document
            inserted_id = current_app.mongo.insert_one(collection_name, data)
            
            return {
                'result': 'Document created',
                'id': inserted_id
            }, 201
            
        except Exception as e:
            return {'error': str(e)}, 500

class MongoDBDocument(Resource):
    @rate_limit
    def get(self, collection_name, document_id):
        """Get a specific document from a collection."""
        try:
            # Find document
            document = current_app.mongo.find_one(collection_name, {'_id': ObjectId(document_id)})
            
            if not document:
                return {'error': 'Document not found'}, 404
                
            # Convert ObjectId to string for JSON serialization
            result = json.loads(dumps(document))
            
            return {'result': result}, 200
            
        except Exception as e:
            return {'error': str(e)}, 500

    @rate_limit
    def put(self, collection_name, document_id):
        """Update a specific document in a collection."""
        try:
            data = request.get_json()
            if not data:
                return {'error': 'No data provided'}, 400
                
            # Update document
            updated = current_app.mongo.update_one(collection_name, {'_id': ObjectId(document_id)}, data)
            
            if updated == 0:
                return {'error': 'Document not found or not modified'}, 404
                
            return {'result': 'Document updated'}, 200
            
        except Exception as e:
            return {'error': str(e)}, 500

    @rate_limit
    def delete(self, collection_name, document_id):
        """Delete a specific document from a collection."""
        try:
            # Delete document
            deleted = current_app.mongo.delete_one(collection_name, {'_id': ObjectId(document_id)})
            
            if deleted == 0:
                return {'error': 'Document not found'}, 404
                
            return {'result': 'Document deleted'}, 200
            
        except Exception as e:
            return {'error': str(e)}, 500

# Register routes
api.add_resource(MongoDBCollection, '/db/<string:collection_name>')
api.add_resource(MongoDBDocument, '/db/<string:collection_name>/<string:document_id>')
EOF

# Update routes.py to import the MongoDB routes
cat > app/api/v1/routes.py.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# Import MongoDB routes\nfrom app.api.v1.mongo_routes import *\n"
    }
  ]
}
EOF

# Update README to include MongoDB info
cat > README.md.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "## Features",
      "content": "## Features\n\n- 🚄 High-performance REST API setup\n- 🔒 Built-in rate limiting\n- 🌐 CORS enabled\n- 📝 Clear project structure\n- 🍃 MongoDB integration"
    },
    {
      "type": "append",
      "content": "\n## MongoDB Integration\n\nThis API includes MongoDB integration with the following endpoints:\n\n- `GET /api/v1/db/<collection>`: Get all documents from a collection\n- `POST /api/v1/db/<collection>`: Create a new document in a collection\n- `GET /api/v1/db/<collection>/<id>`: Get a specific document\n- `PUT /api/v1/db/<collection>/<id>`: Update a specific document\n- `DELETE /api/v1/db/<collection>/<id>`: Delete a specific document\n\nConfigure MongoDB connection in the `.env` file.\n"
    }
  ]
}
EOF

echo "MongoDB integration added successfully"