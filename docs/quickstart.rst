Quick Start
==========

Creating Your First API
----------------------

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
       │   │   └── v1/
       │   ├── models/
       │   ├── services/
       │   ├── utils/
       │   └── config.py
       ├── tests/
       ├── docs/
       └── requirements.txt

3. Running the API:

   .. code-block:: bash

       python run.py

4. Testing the API:

   Open your browser or use curl to test the default endpoints:

   .. code-block:: bash

       curl http://localhost:5000/api/v1/health
       curl http://localhost:5000/api/v1/hello