Database Integration
====================

Flaskify provides seamless integration with multiple database systems, making it easy to persist and manage your application data.

Supported Databases
-------------------

MongoDB
~~~~~~~
Connect to MongoDB for document-based storage:

.. code-block:: python

    from flaskify.db import MongoDBConnection
    
    # Configure MongoDB connection
    db = MongoDBConnection(
        uri="mongodb://localhost:27017",
        database="my_app"
    )

Firebase
~~~~~~~~
Integrate with Firebase Realtime Database:

.. code-block:: python

    from flaskify.db import FirebaseDB
    
    # Initialize Firebase connection
    firebase_db = FirebaseDB(
        credentials_path="path/to/credentials.json",
        database_url="https://your-app.firebaseio.com"
    )

PostgreSQL
~~~~~~~~~~
Use PostgreSQL for relational data:

.. code-block:: python

    from flaskify.db import PostgresConnection
    
    # Set up PostgreSQL connection
    postgres_db = PostgresConnection(
        host="localhost",
        port=5432,
        database="my_app",
        user="username",
        password="password"
    )

Supabase
~~~~~~~~
Connect to Supabase for modern database features:

.. code-block:: python

    from flaskify.db import SupabaseClient
    
    # Initialize Supabase client
    supabase = SupabaseClient(
        url="https://your-project.supabase.co",
        api_key="your-api-key"
    )

Best Practices
--------------

Connection Management
~~~~~~~~~~~~~~~~~~~~~
* Use connection pooling for better performance
* Implement proper error handling
* Close connections when they're no longer needed

Data Models
~~~~~~~~~~~
* Define clear data models
* Use type hints
* Implement data validation

Security
~~~~~~~~
* Never store credentials in code
* Use environment variables
* Implement proper access controls
* Regular security audits
