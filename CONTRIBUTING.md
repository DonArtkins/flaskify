# Flaskify 🚀

<div align="center">

[![Documentation Status](https://readthedocs.org/projects/flaskify/badge/?version=latest)](https://flaskify.readthedocs.io/en/latest/?badge=latest)
[![GitHub license](https://img.shields.io/github/license/DonArtkins/flaskify)](https://github.com/DonArtkins/flaskify/blob/main/LICENSE)
[![Python versions](https://img.shields.io/badge/python-3.8%20%7C%203.9%20%7C%203.10%20%7C%203.11-blue)](https://www.python.org/downloads/)
[![PyPI version](https://badge.fury.io/py/flaskify.svg)](https://badge.fury.io/py/flaskify)

[Documentation](https://flaskify.readthedocs.io/) | [Quick Start](#quick-start) | [Examples](#examples) | [Contributing](CONTRIBUTING.md)

*A lightning-fast Flask REST API generator with built-in ML support, database integrations, and industry best practices* 🌟

</div>

---

## 🌟 Features

<div align="center">

| Core Features | ML Support | Database Integration | DevOps Ready |
|--------------|------------|---------------------|--------------|
| 🚄 High-performance REST API | 🤖 HuggingFace Integration | 📊 MongoDB Support | 🔄 CI/CD Templates |
| 🔒 Rate Limiting & Security | 🧠 Model Training Pipeline | 🔥 Firebase Integration | 🐳 Docker Support |
| 🌐 CORS & Authentication | 📦 Model Management | ⚡ Supabase Ready | 🚀 Heroku Deploy |
| 📝 Auto-documentation | 🎯 Inference API | 🐘 PostgreSQL Support | ☁️ AWS Ready |

</div>

## 📚 Table of Contents

- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [API Development](#-api-development)
  - [Basic Usage](#basic-usage)
  - [Authentication](#authentication)
  - [Rate Limiting](#rate-limiting)
  - [Versioning](#versioning)
- [Database Integration](#-database-integration)
  - [MongoDB Setup](#mongodb-setup)
  - [PostgreSQL Integration](#postgresql-integration)
  - [Firebase Configuration](#firebase-configuration)
  - [Supabase Setup](#supabase-setup)
- [ML Model Integration](#-ml-model-integration)
  - [HuggingFace Models](#huggingface-models)
  - [Custom Models](#custom-models)
  - [Training Pipeline](#training-pipeline)
- [Deployment](#-deployment)
  - [Docker](#docker)
  - [Heroku](#heroku)
  - [AWS](#aws)
- [Contributing](#-contributing)
- [License](#-license)

## 🚀 Installation

### Using pip (Recommended)

```bash
pip install flaskify-generator
```

### Using curl

```bash
# Linux/Mac
curl -s https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.sh | bash

# Windows
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.ps1'))
```

## 🏃 Quick Start

1. **Create a New Project**
   ```bash
   flaskify create my-awesome-api
   cd my-awesome-api
   ```

2. **Set Up Virtual Environment**
   ```bash
   # Linux/Mac
   python -m venv venv
   source venv/bin/activate

   # Windows
   python -m venv venv
   .\venv\Scripts\activate
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the API**
   ```bash
   python run.py
   ```

   Your API is now running at `http://localhost:5000` 🎉

## 📁 Project Structure

```
my-awesome-api/
├── app/
│   ├── api/
│   │   └── v1/                # API version 1
│   │       ├── __init__.py
│   │       └── routes.py
│   ├── models/
│   │   ├── ml/               # ML models
│   │   └── database/         # Database models
│   ├── services/             # Business logic
│   ├── utils/                # Utilities
│   └── config.py             # Configuration
├── tests/                    # Test suite
├── docs/                     # Documentation
└── deployment/               # Deployment configs
```

## 🛠 API Development

### Basic Usage

#### Creating Endpoints

```python
from app.api.v1 import api
from flask_restful import Resource

class UserResource(Resource):
    @api.doc('get_user')
    def get(self, user_id):
        return {'user_id': user_id}

api.add_resource(UserResource, '/users/<int:user_id>')
```

#### Making Requests with Postman

1. **GET Request**
   ```http
   GET http://localhost:5000/api/v1/users/1
   ```

2. **POST Request**
   ```http
   POST http://localhost:5000/api/v1/users
   Content-Type: application/json

   {
     "name": "John Doe",
     "email": "john@example.com"
   }
   ```

### Authentication

```python
from app.utils.auth import require_auth

class SecureResource(Resource):
    @require_auth
    def get(self):
        return {'message': 'secure data'}
```

### Rate Limiting

```python
from app.utils.rate_limit import rate_limit

@rate_limit(requests=100, window=60)  # 100 requests per minute
def my_endpoint():
    return {'status': 'success'}
```

### Versioning

Create new versions in `app/api/v2`, `app/api/v3`, etc.

```python
# app/api/v2/routes.py
from flask import Blueprint

v2_blueprint = Blueprint('v2', __name__, url_prefix='/api/v2')
```

## 💾 Database Integration

### MongoDB Setup

```python
from app.database import mongo

class UserModel(mongo.Document):
    email = mongo.StringField(required=True)
    name = mongo.StringField(required=True)
```

### PostgreSQL Integration

```python
from app.database import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True)
```

### Firebase Configuration

```python
# config/firebase.py
import firebase_admin
from firebase_admin import credentials

cred = credentials.Certificate('path/to/serviceAccount.json')
firebase_admin.initialize_app(cred)
```

### Supabase Setup

```python
from supabase import create_client

supabase = create_client(
    supabase_url='YOUR_SUPABASE_URL',
    supabase_key='YOUR_SUPABASE_KEY'
)
```

## 🤖 ML Model Integration

### HuggingFace Models

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer

def load_model():
    tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
    model = AutoModelForSequenceClassification.from_pretrained("bert-base-uncased")
    return model, tokenizer
```

### Custom Models

```python
# app/models/ml/custom_model.py
class MyModel:
    def train(self, data):
        # Training logic
        pass

    def predict(self, input_data):
        # Prediction logic
        pass
```

### Training Pipeline

```python
# app/models/ml/train.py
def train_model(data_path, save_path):
    model = MyModel()
    data = load_data(data_path)
    model.train(data)
    model.save(save_path)

if __name__ == '__main__':
    train_model('data/training.csv', 'models/my_model.pkl')
```

## 🚢 Deployment

### Docker

```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["python", "run.py"]
```

### Heroku

```bash
heroku create my-awesome-api
git push heroku main
```

### AWS

```bash
aws elasticbeanstalk create-application --application-name my-awesome-api
aws elasticbeanstalk create-environment --environment-name production
```

## 🤝 Contributing

We love contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details.
