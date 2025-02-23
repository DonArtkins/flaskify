Installation
============

Prerequisites
-------------

* Python 3.8 or higher
* pip (Python package installer)
* Git (optional)

Installation Methods
--------------------

Using pip
~~~~~~~~~

The recommended way to install Flaskify is using pip:

.. code-block:: bash

    pip install flaskify-generator

Using curl (Linux/Mac)
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    curl -s https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.sh | bash

Using PowerShell (Windows)
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: powershell

    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DonArtkins/flaskify/master/flaskify-install.ps1'))

Verifying Installation
----------------------

After installation, verify that Flaskify is working correctly:

.. code-block:: bash

    flaskify --version