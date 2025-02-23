Contributing
===========

Thank you for considering contributing to Flaskify! This document provides guidelines and instructions for contributing.

Getting Started
-------------

Development Setup
~~~~~~~~~~~~~~~

1. Fork the repository
2. Clone your fork:

   .. code-block:: bash

       git clone https://github.com/your-username/flaskify.git
       cd flaskify

3. Create a virtual environment:

   .. code-block:: bash

       python -m venv venv
       source venv/bin/activate  # Linux/Mac
       .\venv\Scripts\activate   # Windows

4. Install development dependencies:

   .. code-block:: bash

       pip install -r requirements-dev.txt

Code Style
---------

Guidelines
~~~~~~~~~
* Follow PEP 8 style guide
* Use meaningful variable names
* Write descriptive docstrings
* Add type hints
* Keep functions focused and small

Testing
------

Running Tests
~~~~~~~~~~~
Run the test suite:

.. code-block:: bash

    pytest

Adding Tests
~~~~~~~~~~
* Write tests for new features
* Maintain test coverage
* Use meaningful test names
* Include edge cases

Pull Requests
-----------

Submission Process
~~~~~~~~~~~~~~~~
1. Create a new branch
2. Make your changes
3. Write tests
4. Update documentation
5. Submit PR

PR Guidelines
~~~~~~~~~~~
* Clear description
* Reference related issues
* Include test results
* Update changelog
* Follow code style

Documentation
-----------

Building Docs
~~~~~~~~~~~
Generate documentation:

.. code-block:: bash

    cd docs
    make html

Writing Docs
~~~~~~~~~~
* Clear and concise
* Include examples
* Update relevant sections
* Check for typos
