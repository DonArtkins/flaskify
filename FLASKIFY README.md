# Flaskify

```
flaskify/
├── cli/
│   ├── __init__.py
│   ├── commands/
│   │   ├── __init__.py
│   │   ├── create.py        # Command to create new projects
│   │   └── version.py       # Command to manage versions
│   ├── interactive/
│   │   ├── __init__.py
│   │   ├── prompts.py       # Interactive CLI prompts
│   │   └── templates.py     # Template selection logic
│   └── utils/
│       ├── __init__.py
│       └── helpers.py       # CLI helper functions
├── templates/
│   ├── v1.0.0/              # Your current version
│   │   ├── basic/           # Basic template structure 
│   │   ├── with_mongodb/     
│   │   ├── with_postgres/
│   │   ├── with_ml/
│   │   └── full/            # Full template with all features
│   ├── v1.0.1/              # Future version
│   │   ├── ...
│   └── v1.0.2/              # Future version
│       ├── ...
├── versioned/
│   ├── v1.0.0/
│   │   ├── flaskify-template.sh    # Your current template script
│   │   ├── flaskify-install.sh     # Installation script for v1.0.0
│   │   └── flaskify-install.ps1    # Windows install for v1.0.0
│   ├── v1.0.1/
│   │   └── ... 
│   └── v1.0.2/
│       └── ...
├── docs/
│   ├── versions/
│   │   ├── v1.0.0/          # Documentation for v1.0.0
│   │   │   ├── index.rst
│   │   │   ├── quickstart.rst
│   │   │   └── ...
│   │   ├── v1.0.1/
│   │   └── v1.0.2/
│   └── index.rst            # Main documentation entry
├── tests/
│   ├── integration/
│   ├── unit/
│   └── versioned/           # Version-specific tests
│       ├── v1.0.0/
│       ├── v1.0.1/
│       └── v1.0.2/
├── .gitignore
├── CONTRIBUTING.md
├── LICENSE
├── README.md               # Updated to include versioning info
├── flaskify-install.sh     # Main installer that calls versioned installers
├── flaskify-install.ps1    # Windows installer that calls versioned installers
├── pyproject.toml          # Modern Python packaging
└── setup.py                # Setup script
```

## Version Management Guide

### Adding New Versions:
1. Create new directory in `versioned/`
2. Copy previous version files as base
3. Update implementation
4. Add version-specific tests
5. Create documentation in `docs/versions/`

### Documenting Versions:
- Add API reference in `versions/<VERSION>/api.rst`
- Update features in `versions/<VERSION>/features.rst`
- Include migration guides when applicable

### Maintaining Backward Compatibility:
- Keep core functionality in `flaskify/core`
- Version-specific overrides in `versioned/`
- Test all versions in CI/CD pipelines