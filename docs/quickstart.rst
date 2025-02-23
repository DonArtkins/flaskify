Quick Start
===========

Creating Your First API
-----------------------

1. Create a new project:

   .. code-block:: bash

       flaskify create my-awesome-api
       cd my-awesome-api

2. Project Structure
   
   Your new project will have the following structure:

   .. code-block:: text

       my-awesome-api/
       ├── app/
       │   ├── api/
       │   │   └── v1/              # API version 1
       │   │       ├── __init__.py  # Initializes the v1 API
       │   │       └── routes.py    # Defines API endpoints
       │   ├── config/
       │   │   └── config.py        # Configuration settings
       │   ├── models/             # Store your ML models here
       │   │   ├── __init__.py
       │   │   └── trained_models/ # Directory for saved models
       │   ├── services/          # Business logic and model inference
       │   │   └── __init__.py
       │   ├── utils/
       │   │   └── helpers.py      # Utility functions (e.g., rate limiting)
       │   └── __init__.py         # Initializes the app package
       ├── tests/                # Add your unit tests here
       ├── docs/                 # API documentation
       ├── venv/                 # Virtual environment
       ├── .env                  # Environment variables
       ├── .gitignore           # Git ignore rules
       ├── LICENSE              # License information
       ├── CONTRIBUTING.md      # Contribution guidelines
       ├── README.md            # This file!
       ├── requirements.txt     # Python package dependencies
       └── run.py              # Main application entry point

3. Running the API:

   .. code-block:: bash

       python3 run.py

4. Testing the API:

   Open your browser or use curl to test the default endpoints:

   .. code-block:: bash

       curl http://localhost:5000/api/v1/health
       curl http://localhost:5000/api/v1/hello