```
templates/
├── v1.0.0/
│   ├── basic/ (Core files for all projects)
│   │   ├── app/
│   │   │   ├── __init__.py
│   │   │   ├── api/
│   │   │   │   ├── __init__.py
│   │   │   │   └── v1/
│   │   │   │       ├── __init__.py
│   │   │   │       └── routes.py
│   │   │   ├── config/
│   │   │   │   └── config.py
│   │   │   └── utils/
│   │   │       └── helpers.py
│   │   ├── .env
│   │   ├── .gitignore
│   │   ├── run.py
│   │   └── requirements.txt
│   ├── with_mongodb/ (MongoDB-specific files)
│   │   ├── app/
│   │   │   ├── db/
│   │   │   │   ├── __init__.py
│   │   │   │   └── mongo.py
│   │   │   └── models/
│   │   │       └── base_model.py
│   │   └── requirements-mongodb.txt
│   ├── with_postgres/ (PostgreSQL-specific files)
│   ├── with_ml/ (ML integration files)
│   └── ...
└── v1.0.1/
    └── ... (newer version templates)
```