```bash
#!/bin/bash

# Flaskify - ML Model Support Template Extension
set -e  # Exit on error

echo "Adding ML model support..."

# Create ML directories
mkdir -p "app/models/ml"
mkdir -p "app/services"
touch "app/models/ml/__init__.py"
touch "app/services/__init__.py"

# Create ML model loader
cat > app/services/ml_service.py << EOF
import os
import pickle
import numpy as np
import joblib
from flask import current_app
import time
from pathlib import Path

class MLService:
    """Service for loading and using ML models."""
    
    def __init__(self, app=None):
        self.models = {}
        self.model_dir = None
        
        if app is not None:
            self.init_app(app)
    
    def init_app(self, app):
        """Initialize with Flask app."""
        self.model_dir = Path(app.config.get('ML_MODEL_DIR', 'models'))
        
        # Create models directory if it doesn't exist
        if not self.model_dir.exists():
            self.model_dir.mkdir(parents=True, exist_ok=True)
        
        # Preload models if configured
        if app.config.get('ML_PRELOAD_MODELS', False):
            self._preload_models()
        
        # Add ML service to app
        app.ml = self
        
        # Log configuration
        app.logger.info(f"ML service initialized with model directory: {self.model_dir}")
    
    def _preload_models(self):
        """Preload all available models."""
        model_files = list(self.model_dir.glob('*.pkl')) + list(self.model_dir.glob('*.joblib'))
        
        for model_file in model_files:
            model_name = model_file.stem
            self.load_model(model_name)
    
    def load_model(self, model_name):
        """Load a model by name."""
        if model_name in self.models:
            return self.models[model_name]
        
        # Try different extensions
        for ext in ['.pkl', '.joblib']:
            model_path = self.model_dir / f"{model_name}{ext}"
            if model_path.exists():
                start_time = time.time()
                
                # Load the model based on extension
                if ext == '.pkl':
                    with open(model_path, 'rb') as f:
                        model = pickle.load(f)
                else:  # .joblib
                    model = joblib.load(model_path)
                
                load_time = time.time() - start_time
                self.models[model_name] = model
                
                current_app.logger.info(f"Model '{model_name}' loaded in {load_time:.2f}s")
                return model
        
        raise FileNotFoundError(f"Model '{model_name}' not found in {self.model_dir}")
    
    def predict(self, model_name, data):
        """Make a prediction using a model."""
        # Load model if not already loaded
        if model_name not in self.models:
            self.load_model(model_name)
        
        model = self.models[model_name]
        
        # Convert data to numpy array if needed
        if isinstance(data, list):
            data = np.array(data)
        
        # Make prediction
        start_time = time.time()
        prediction = model.predict(data)
        prediction_time = time.time() - start_time
        
        current_app.logger.debug(f"Prediction with model '{model_name}' took {prediction_time:.4f}s")
        
        # Convert numpy types to Python native types for JSON serialization
        if isinstance(prediction, np.ndarray):
            prediction = prediction.tolist()
        
        return prediction
EOF

# Create ML model example
cat > app/models/ml/example_model.py << EOF
import numpy as np
from sklearn.linear_model import LinearRegression
import joblib
import os

class ExampleModel:
    """Example ML model class."""
    
    def __init__(self):
        """Initialize the model."""
        self.model = LinearRegression()
        self.is_trained = False
    
    def train(self, X, y):
        """Train the model."""
        self.model.fit(X, y)
        self.is_trained = True
        return self
    
    def predict(self, X):
        """Make predictions."""
        if not self.is_trained:
            raise ValueError("Model is not trained yet")
        return self.model.predict(X)
    
    def save(self, filename):
        """Save the model to disk."""
        if not self.is_trained:
            raise ValueError("Cannot save untrained model")
        
        joblib.dump(self.model, filename)
        return filename
    
    @classmethod
    def load(cls, filename):
        """Load a model from disk."""
        instance = cls()
        instance.model = joblib.load(filename)
        instance.is_trained = True
        return instance
    
    @classmethod
    def create_example_model(cls, save_path='models/linear_model.joblib'):
        """Create and save an example model."""
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(save_path), exist_ok=True)
        
        # Generate synthetic data
        np.random.seed(42)
        X = np.random.rand(100, 2)
        y = 3 * X[:, 0] + 2 * X[:, 1] + 1 + 0.1 * np.random.randn(100)
        
        # Train the model
        model = cls().train(X, y)
        
        # Save the model
        model.save(save_path)
        
        return save_path
EOF

# Create ML endpoints
cat > app/api/v1/ml_routes.py << EOF
from flask import request, current_app, jsonify
from flask_restful import Resource
from app.api.v1 import api
from app.utils.helpers import rate_limit
import numpy as np
import os
from app.models.ml.example_model import ExampleModel

class ModelList(Resource):
    @rate_limit
    def get(self):
        """List available ML models."""
        try:
            model_dir = current_app.config.get('ML_MODEL_DIR', 'models')
            
            # Check if directory exists
            if not os.path.exists(model_dir):
                return {'models': []}, 200
            
            # List models
            models = []
            for file in os.listdir(model_dir):
                if file.endswith('.pkl') or file.endswith('.joblib'):
                    models.append(os.path.splitext(file)[0])
            
            return {'models': models}, 200
        except Exception as e:
            return {'error': str(e)}, 500

class ModelPrediction(Resource):
    @rate_limit
    def post(self, model_name):
        """Make a prediction with a model."""
        try:
            data = request.get_json()
            
            if not data or 'features' not in data:
                return {'error': 'Missing features in request'}, 400
            
            features = data['features']
            
            # Make prediction
            prediction = current_app.ml.predict(model_name, [features])
            
            return {
                'model': model_name,
                'prediction': prediction,
                'features': features
            }, 200
        except FileNotFoundError as e:
            return {'error': str(e)}, 404
        except Exception as e:
            return {'error': str(e)}, 500

class CreateExampleModel(Resource):
    @rate_limit
    def post(self):
        """Create an example linear regression model."""
        try:
            model_dir = current_app.config.get('ML_MODEL_DIR', 'models')
            os.makedirs(model_dir, exist_ok=True)
            
            model_path = os.path.join(model_dir, 'linear_model.joblib')
            ExampleModel.create_example_model(model_path)
            
            # Reload models in service
            if hasattr(current_app, 'ml'):
                current_app.ml.load_model('linear_model')
            
            return {
                'message': 'Example model created successfully',
                'model_name': 'linear_model',
                'path': model_path
            }, 201
        except Exception as e:
            return {'error': str(e)}, 500

# Register routes
api.add_resource(ModelList, '/ml/models')
api.add_resource(ModelPrediction, '/ml/predict/<string:model_name>')
api.add_resource(CreateExampleModel, '/ml/example')
EOF

# Update app/__init__.py to include ML service
cat > app/__init__.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "from flask import Flask",
      "content": "from flask import Flask\nfrom app.services.ml_service import MLService"
    },
    {
      "type": "replace",
      "target": "# Initialize extensions\n    CORS(app)",
      "content": "# Initialize extensions\n    CORS(app)\n    # Initialize ML service\n    ml_service = MLService(app)"
    }
  ]
}
EOF

# Update config.py to include ML settings
cat > app/config/config.py.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "class Config:",
      "content": "class Config:\n    # ML Configuration\n    ML_MODEL_DIR = os.getenv('ML_MODEL_DIR', os.path.join(basedir, '../../models'))\n    ML_PRELOAD_MODELS = os.getenv('ML_PRELOAD_MODELS', 'False').lower() in ('true', '1', 't')"
    }
  ]
}
EOF

# Update .env to include ML settings
cat > .env.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# ML Configuration\nML_MODEL_DIR=models\nML_PRELOAD_MODELS=True\n"
    }
  ]
}
EOF

# Update requirements.txt to include ML libraries
cat > requirements.txt.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# ML Libraries\nscikit-learn==1.4.0\nnumpy==1.26.3\njoblib==1.3.2\n"
    }
  ]
}
EOF

# Update routes.py to import the ML routes
cat > app/api/v1/routes.py.merge << EOF
{
  "operations": [
    {
      "type": "append",
      "content": "\n# Import ML routes\nfrom app.api.v1.ml_routes import *\n"
    }
  ]
}
EOF

# Create models directory
mkdir -p "models"

# Update README to include ML info
cat > README.md.merge << EOF
{
  "operations": [
    {
      "type": "replace",
      "target": "## Features",
      "content": "## Features\n\n- 🚄 High-performance REST API setup\n- 🔒 Built-in rate limiting\n- 🌐 CORS enabled\n- 📝 Clear project structure\n- 🤖 Machine Learning model support"
    },
    {
      "type": "append",
      "content": "\n## Machine Learning Integration\n\nThis API includes ML model support with the following endpoints:\n\n- `GET /api/v1/ml/models`: List available ML models\n- `POST /api/v1/ml/predict/<model_name>`: Make predictions with a model\n- `POST /api/v1/ml/example`: Create an example linear regression model\n\nExample prediction request:\n\n```json\n{\n  \"features\": [0.5, 0.7]\n}\n```\n\nML models are stored in the `models` directory and can be loaded dynamically.\n"
    }
  ]
}
EOF

echo "ML model support added successfully"
```