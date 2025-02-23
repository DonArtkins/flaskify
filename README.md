# Flaskify 🚀

A minimalist, high-performance Flask REST API Template with built-in rate limiting and best practices.  This is a great starting point for building robust APIs.

## Features

- 🚄 High-performance REST API setup
- 🔒 Built-in rate limiting (configurable)
- 🌐 CORS enabled (for cross-origin requests)
- 📝 Clear project structure
- 🔄 Version control ready (Git pre-initialized)
- 📦 Minimal dependencies

## Installation

### Linux/Mac

```bash
# Install Flaskify CLI
curl -s https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.sh | bash
```
```bash
# Create new project
flaskify create my-api
```

### Windows

```powershell
# Install Flaskify CLI
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.sh'))
```
```bash
# Create new project
flaskify create my-api
```

## Quick Start

1.  **Create a New Project:**

    ```bash
    flaskify create my-api
    ```
    ```bash
    cd my-api
    ```

2.  **Activate the Virtual Environment:**

    ```bash
    # Linux/Mac
    source venv/bin/activate
    ```
    ```bash
    # Windows
    .\venv\Scripts\activate
    ```

3.  **Install Dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

4.  **Run the API:**

    ```bash
    python run.py
    ```

    The API will start in debug mode.  You'll see output in your terminal.

## API Structure

The project follows a clear structure:

```
my-api/
├── app/
│   ├── api/
│   │   └── v1/              # API version 1
│   │       ├── __init__.py  # Initializes the v1 API
│   │       └── routes.py    # Defines API endpoints
│   ├── config/
│   │   └── config.py        # Configuration settings
│   ├── utils/
│   │   └── helpers.py       # Utility functions (e.g., rate limiting)
│   └── __init__.py          # Initializes the app package
├── tests/                 # (Placeholder)  Add your unit tests here
├── docs/                  # (Placeholder)  Add your API documentation here
├── venv/                  # Virtual environment
├── .env                   # Environment variables (sensitive information)
├── .gitignore             # Specifies intentionally untracked files that Git should ignore
├── LICENSE                # License information
├── CONTRIBUTING.md        # Contribution guidelines
├── README.md              # This file!
├── requirements.txt       # Lists Python package dependencies
└── run.py                 # Main application entry point
```

## Configuration

API configuration is managed through environment variables. Create a `.env` file in the root directory of your project.  Example:

```
SECRET_KEY=your-super-secret-key  # Change this!  Generate a strong, random key.
API_TITLE=My Awesome API
API_VERSION=v1
RATE_LIMIT=1000
RATE_LIMIT_PERIOD=15
```

**Important:**

*   **`SECRET_KEY`**:  This is crucial for security.  Generate a strong, random key using `secrets.token_hex(32)` in Python and set it as an environment variable.  *Never* commit your secret key to version control.
*   **Don't store sensitive information directly in your code.**  Use environment variables.

## Deployment

Flaskify is designed for easy deployment.  Here are some options:

### Heroku

1.  **Create a Heroku Account:**  If you don't have one, sign up at [https://www.heroku.com/](https://www.heroku.com/).

2.  **Install the Heroku CLI:**  Follow the instructions on the Heroku website.

3.  **Log in to Heroku:**

    ```bash
    heroku login
    ```

4.  **Create a Heroku App:**

    ```bash
    heroku create my-api-name  # Replace with a unique name
    ```

5.  **Set the `SECRET_KEY` Environment Variable:**

    ```bash
    heroku config:set SECRET_KEY=$(python -c "import secrets; print(secrets.token_hex(32))")
    ```

6.  **Deploy the App:**

    ```bash
    git push heroku main
    ```

    Heroku will automatically detect your Flask app and deploy it.

### Docker

1.  **Install Docker:**  Download and install Docker Desktop from [https://www.docker.com/](https://www.docker.com/).

2.  **Create a `Dockerfile`:**  In the root of your project, create a file named `Dockerfile` with the following contents:

    ```dockerfile
    FROM python:3.9-slim-buster

    WORKDIR /app

    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt

    COPY . .

    # Set environment variables (you can also pass these at runtime)
    ENV FLASK_APP=run.py
    ENV FLASK_RUN_HOST=0.0.0.0  # Listen on all interfaces

    EXPOSE 5000

    CMD ["flask", "run"]
    ```

3.  **Build the Docker Image:**

    ```bash
    docker build -t my-api .
    ```

4.  **Run the Docker Container:**

    ```bash
    docker run -p 5000:5000 -e SECRET_KEY=$(python -c "import secrets; print(secrets.token_hex(32))") my-api
    ```

    *   `-p 5000:5000`: Maps port 5000 on your host to port 5000 in the container.
    *   `-e SECRET_KEY=...`:  Sets the `SECRET_KEY` environment variable.

### Railway

1.  **Create a Railway Account:**  If you don't have one, sign up at [https://railway.app/](https://railway.app/).

2.  **Install the Railway CLI:**  Follow the instructions on the Railway website.

3.  **Log in to Railway:**

    ```bash
    railway login
    ```

4.  **Initialize a Railway Project:**

    ```bash
    railway init
    ```

5.  **Deploy to Railway:**

    ```bash
    railway up
    ```

6.  **Set the `SECRET_KEY` Environment Variable:**  In the Railway dashboard, add a new variable called `SECRET_KEY` and set its value to a strong, randomly generated key.

## Rate Limiting

The API includes basic rate limiting to prevent abuse.

*   **Default:** 1000 requests per 15 minutes.
*   **Configuration:**  Adjust the `RATE_LIMIT` and `RATE_LIMIT_PERIOD` environment variables in your `.env` file.

## Best Practices

Flaskify promotes best practices:

*   ✅ **RESTful Routing:**  Follow RESTful principles for API design.
*   ✅ **Rate Limiting:**  Protect your API from excessive requests.
*   ✅ **Error Handling:** Implement proper error handling for a better user experience.
*   ✅ **Configuration Management:** Use environment variables for configuration.
*   ✅ **API Versioning:**  Organize your API by version.
*   ✅ **CORS Support:**  Enable Cross-Origin Resource Sharing (CORS) for web applications.
*   ✅ **Clean Project Structure:** Maintain a well-organized project.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for details on how to contribute to this project.

## License

MIT License.  See [LICENSE](LICENSE) for more information.
