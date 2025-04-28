# Flaskify Projects 🚀

<div align="center">

[![Documentation Status](https://readthedocs.org/projects/flaskify/badge/?version=latest)](https://flaskify.readthedocs.io/en/latest/?badge=latest)
[![GitHub license](https://img.shields.io/github/license/DonArtkins/flaskify)](https://github.com/DonArtkins/flaskify/blob/main/LICENSE)
[![Python versions](https://img.shields.io/badge/python-3.8%20%7C%203.9%20%7C%203.10%20%7C%203.11-blue)](https://www.python.org/downloads/)
[![PyPI version](https://badge.fury.io/py/flaskify.svg)](https://badge.fury.io/py/flaskify)

[DOCUMENTATION](https://flaskify.readthedocs.io/en/latest/index.html) | [CONTRIBUTING](CONTRIBUTING.md) | [LICENSE](LICENSE)

*A lightning-fast Flask REST API generator with built-in ML support, database integrations, versioning, and industry best practices* 🌟

</div>

---

## 🌟 Features

<div align="center">

| Core Features | ML Support | Database Integration | DevOps Ready |
|--------------|------------|---------------------|--------------|
| 🚄 High-performance REST API | 🤖 HuggingFace Integration | 📊 MongoDB Support | 🔄 CI/CD Templates |
| 🔒 Rate Limiting & Security | 🧠 Model Training Pipeline | 🔥 Firebase Integration | 🐳 Docker Support |
| 🌐 CORS & Authentication | 📦 Model Management | ⚡ Supabase Ready | 🚀 Heroku Deploy |
| 📝 Interactive Project Setup | 🎯 Inference API | 🐘 PostgreSQL Support | 🔄 Version Management |

</div>

## 📚 Table of Contents

- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Version Management](#-version-management)
- [Project Structure](#-project-structure)
- [API Development](#-api-development)
- [Database Integration](#-database-integration)
- [ML Model Integration](#-ml-model-integration)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [License](#-license)

## 🚀 Installation

### Using curl (Recommended)

```bash
# Linux/Mac
curl -s https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.sh | bash
```
```bash
# Windows
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.ps1'))
```

### Using pip

```bash
pip install flaskify
```

## 🏃 Quick Start

1. **Create a New Project Interactively**
   ```bash
   flaskify create
   ```

2. **Follow the Interactive Prompts**
   - Enter your project name
   - Select Flaskify version
   - Choose features and integrations
   - Confirm your selections

3. **Navigate to Your Project**
   ```bash
   cd my-awesome-api
   ```

4. **Activate Virtual Environment**
   ```bash
   # Linux/Mac
   source venv/bin/activate
   ```
   ```bash
   # Windows
   .\venv\Scripts\activate
   ```

5. **Run the API**
   ```bash
   python run.py
   ```

   Your API is now running at `http://localhost:5000` 🎉

## 🔄 Version Management

Flaskify supports multiple versions, allowing you to choose the right feature set for your project needs.

### Available Versions

- **v1.0.0** - Initial release with core features
- **v1.0.1** - Enhanced database support and optimizations
- **v1.0.2** - Advanced ML integration and security features

### Checking Available Versions

```bash
flaskify versions
```

### Setting Default Version

```bash
flaskify set-version v1.0.1
```

### Version Compatibility

Each version maintains backward compatibility with previous versions, with documentation for migration paths between versions.

## 📁 Project Structure

The generated project follows a well-organized structure with version-specific customizations:

```
my-awesome-api/
├── app/
│   ├── api/
│   │   └── v1/              # API version 1 
│   ├── config/              # Configuration settings
│   ├── models/              # Database models & ML models
│   ├── services/            # Business logic
│   ├── utils/               # Utility functions
│   └── __init__.py          # App initialization
├── tests/                   # Test suite
├── docs/                    # API documentation
├── deployment/              # Deployment configurations
├── venv/                    # Virtual environment
├── .env                     # Environment variables
├── .gitignore               # Git ignore rules
├── README.md                # Project documentation
├── requirements.txt         # Python dependencies
└── run.py                   # Entry point
```

## 🛠 API Development

Flaskify generates a production-ready API foundation with:

### RESTful Endpoints

```python
# Example endpoint from generated code
class UserResource(Resource):
    @api.doc('get_user')
    @rate_limit
    def get(self, user_id):
        return {'user_id': user_id}

api.add_resource(UserResource, '/users/<int:user_id>')
```

### Built-in Security

- Automatic rate limiting
- CORS configuration
- Authentication frameworks

### API Versioning

Flaskify supports API versioning out of the box, allowing you to maintain multiple API versions simultaneously.

## 💾 Database Integration

Choose from multiple database options during project creation:

### MongoDB Support

```python
# Example MongoDB integration from generated code
from app.database import mongo

class UserModel(mongo.Document):
    email = mongo.StringField(required=True)
    name = mongo.StringField(required=True)
```

### PostgreSQL Support

```python
# Example PostgreSQL integration from generated code
from app.database import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True)
```

### Firebase & Supabase

Integrated support for modern cloud databases with ready-to-use configurations.

## 🤖 ML Model Integration

Optional ML support includes:

- HuggingFace integration
- Model training pipeline
- Inference API endpoints
- Model management and versioning

## 🚢 Deployment

Choose deployment targets during project setup:

- Docker containerization
- Heroku deployment
- AWS configuration
- CI/CD pipeline templates

## 🤝 Contributing

We welcome contributions to Flaskify! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Code style
- Pull request process
- Documentation standards
- Testing requirements

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details.