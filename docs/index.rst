Flaskify Documentation
======================

.. image:: https://readthedocs.org/projects/flaskify/badge/?version=latest
    :target: https://flaskify.readthedocs.io/en/latest/?badge=latest
    :alt: Documentation Status

.. image:: https://img.shields.io/github/license/DonArtkins/flaskify
    :target: https://github.com/DonArtkins/flaskify/blob/main/LICENSE
    :alt: GitHub license

.. image:: https://img.shields.io/badge/python-3.8%20%7C%203.9%20%7C%203.10%20%7C%203.11-blue
    :target: https://www.python.org/downloads/
    :alt: Python versions

A lightning-fast Flask REST API generator with built-in ML support, database integrations, and industry best practices.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   quickstart
   project_structure
   database_integration
   ml_integration
   deployment
   contributing
   changelog

Features
--------

Core Features
~~~~~~~~~~~~~
* High-performance REST API
* Rate Limiting & Security
* CORS & Authentication
* Auto-documentation

ML Support
~~~~~~~~~~
* HuggingFace Integration
* Model Training Pipeline
* Model Management
* Inference API

Database Integration
~~~~~~~~~~~~~~~~~~~~
* MongoDB Support
* Firebase Integration
* Supabase Ready
* PostgreSQL Support

DevOps Ready
~~~~~~~~~~~~
* CI/CD Templates
* Docker Support
* Heroku Deploy
* AWS Ready

Getting Started
---------------

Installation
~~~~~~~~~~~~
Using pip (Recommended):

.. code-block:: bash

    pip install flaskify-generator

Using curl:

.. code-block:: bash

    # Linux/Mac
    curl -s https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.sh | bash

Quick Start
~~~~~~~~~~~

1. Create a new project:

   .. code-block:: bash

       flaskify create my-awesome-api
       cd my-awesome-api

2. Set up virtual environment:

   .. code-block:: bash

       python -m venv venv
       source venv/bin/activate  # Linux/Mac
       .\venv\Scripts\activate   # Windows

3. Install dependencies:

   .. code-block:: bash

       pip install -r requirements.txt

4. Run the API:

   .. code-block:: bash

       python run.py

Your API will be running at ``http://localhost:5000``
