# Flaskify 🚀

<div align="center">

[![Documentation Status](https://readthedocs.org/projects/flaskify/badge/?version=latest)](https://flaskify.readthedocs.io/en/latest/?badge=latest)
[![GitHub license](https://img.shields.io/github/license/DonArtkins/flaskify)](https://github.com/DonArtkins/flaskify/blob/main/LICENSE)
[![Python versions](https://img.shields.io/badge/python-3.8%20%7C%203.9%20%7C%203.10%20%7C%203.11-blue)](https://www.python.org/downloads/)
[![PyPI version](https://badge.fury.io/py/flaskify.svg)](https://badge.fury.io/py/flaskify)
![Flask](https://img.shields.io/badge/Flask-2.0+-orange)
![Version](https://img.shields.io/badge/Flaskify-v1.0.0-blue)

*A lightning-fast Flask REST API generator with built-in ML support, database integrations, and industry best practices* 🌟

[DOCUMENTATION](https://flaskify.readthedocs.io/en/latest/index.html) | [CONTRIBUTING](CONTRIBUTING.md) | [LICENSE](LICENSE)

</div>

---

## 🚀 Features

- **Quick Project Setup**: Generate a complete Flask API project in seconds
- **Multiple Database Support**: Integration with MongoDB, PostgreSQL, Firebase, and Supabase
- **Authentication Ready**: JWT, OAuth2, and Basic authentication options
- **ML Model Support**: Easy integration of machine learning models
- **API Documentation**: Automatic Swagger/OpenAPI documentation
- **Deployment Ready**: Configuration for Docker, Heroku, and AWS
- **Testing Framework**: Pytest setup included
- **Asynchronous Support**: Optional async endpoints
- **Version Management**: Multiple template versions available

## 📋 Requirements

- Python 3.7+
- Git

## 💻 Installation

### Linux/macOS

```bash
curl -s https://raw.githubusercontent.com/DonArtkins/flaskify/master/installers/linux/install.sh | bash
```

### Windows

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/DonArtkins/flaskify/master/installers/windows/install.ps1 -OutFile install.ps1; .\install.ps1
```

Or clone the repository and install manually:

```bash
git clone https://github.com/DonArtkins/flaskify.git
cd flaskify
pip install -e .
```

## 🛠️ Usage

### Create a New Project

```bash
flaskify create
```

Follow the interactive prompts to configure your project:
- Project name
- Database integration
- ML model support
- Deployment target
- Authentication method
- Swagger documentation
- Async endpoints
- Testing setup

### Additional Commands

```bash
flaskify versions        # Check available versions
flaskify set_version v1.0.0  # Set default version
flaskify info            # Show Flaskify info
```

## 📂 Project Structure

When you create a new project with Flaskify, it generates a structure like:

```
my_api/
├── app/
│   ├── __init__.py
│   ├── routes/
│   ├── models/
│   ├── services/
│   └── utils/
├── config/
│   └── config.py
├── tests/
├── requirements.txt
├── run.py
└── README.md
```

## 🔌 Supported Integrations

### Databases
- **MongoDB**: Document-based NoSQL database
- **PostgreSQL**: Relational database
- **Firebase**: Google's mobile and web application platform
- **Supabase**: Open source Firebase alternative

### Authentication
- **JWT**: JSON Web Token authentication
- **OAuth2**: Authorization framework
- **Basic**: Simple username/password authentication

### Deployment
- **Docker**: Containerization for consistent deployment
- **Heroku**: PaaS for easy cloud deployment
- **AWS**: Amazon Web Services deployment configuration

## 🤖 ML Support

When enabled, Flaskify adds:
- Model loading/inference endpoints
- File upload for model inputs
- Example prediction route
- Format conversion utilities

## 🧪 Testing

Includes pytest setup with:
- Fixture examples
- API test examples
- Test configuration

## 🛣️ Roadmap

- GraphQL support
- Additional database integrations
- WebSocket support
- Admin dashboard
- CI/CD pipeline templates

## 👥 Contributing

Contributions are welcome! Please check out our [contributing guidelines](CONTRIBUTING.md).

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [Flask](https://flask.palletsprojects.com/)
- [Click](https://click.palletsprojects.com/)
- [Inquirer](https://github.com/magmax/python-inquirer)
- All the amazing open-source projects that made this possible

---

Created with ❤️ by [DonArtkins](https://github.com/DonArtkins)