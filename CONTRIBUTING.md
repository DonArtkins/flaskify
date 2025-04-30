# Contributing to Flaskify

🎉 First of all, thank you for considering contributing to Flaskify! 🎉

This document provides guidelines and steps for contributing to this project. By participating in this project, you agree to abide by our [Code of Conduct](#code-of-conduct).

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
  - [Development Environment Setup](#development-environment-setup)
  - [Project Structure](#project-structure)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Style Guidelines](#style-guidelines)
  - [Code Style](#code-style)
  - [Commit Messages](#commit-messages)
- [Testing](#testing)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

Our project is committed to fostering an open and welcoming environment. By participating, you are expected to uphold this code. Please report unacceptable behavior to [project@flaskify.dev](mailto:project@flaskify.dev).

We expect all contributors to:
- Be respectful and inclusive
- Exercise empathy and kindness
- Provide and gracefully accept constructive feedback
- Focus on what's best for the community

## Getting Started

### Project Structure

```
flaskify/
├── flaskify/             # Main package
│   ├── __init__.py
│   ├── cli/              # Command-line interface
│   ├── templates/        # Project templates
│   ├── generators/       # Code generators
│   └── utils/            # Utility functions
├── tests/                # Test directory
├── docs/                 # Documentation
├── examples/             # Example projects
└── scripts/              # Utility scripts
```

## How to Contribute

### Reporting Bugs

Before submitting a bug report:
- Check the [issue tracker](https://github.com/DonArtkins/flaskify/issues) to see if the problem has already been reported
- Ensure you're using the latest version of Flaskify

When submitting a bug report:
1. Use the bug report template
2. Include detailed steps to reproduce the issue
3. Describe the expected vs. actual behavior
4. Include environment details (OS, Python version, etc.)
5. Include any relevant logs or screenshots

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues:
1. Use the feature request template
2. Provide a clear and detailed explanation of the feature
3. Explain why this enhancement would be useful to most Flaskify users
4. Include code examples if applicable
5. List any alternatives you've considered

### Pull Requests

Follow these steps to submit a pull request:

1. **Create a new branch from `main`**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write your code
   - Add or update tests as needed
   - Update documentation

3. **Test your changes**
   ```bash
   pytest
   ```

4. **Commit your changes**
   ```bash
   git commit -m "Add feature: your feature description"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Submit a pull request**
   - Fill out the pull request template
   - Reference any related issues
   - Wait for review by maintainers

7. **Code Review**
   - Address any feedback or requested changes
   - Update your branch if needed

## Style Guidelines

### Code Style

We follow PEP 8 coding style guidelines with a few project-specific rules:
- Use 4 spaces for indentation
- Maximum line length of 88 characters (using Black formatter)
- Use descriptive variable names
- Write docstrings in Google format

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests after the first line

## Testing

We use pytest for testing. All new code should include appropriate tests:

- Unit tests for individual functions
- Integration tests for features
- Tests should be placed in the `tests/` directory
- Name test files with `test_` prefix

## Documentation

Good documentation is crucial:

- Update README.md if necessary
- Add or update docstrings for public APIs
- Update the documentation in the `docs/` directory
- Add examples for new features in the `examples/` directory

Documentation uses Sphinx and is hosted on Read the Docs. Build the docs locally with:
```bash
cd docs
# Then add your documentation
```

## Community

- Join our [Discord server](https://discord.gg/flaskify) for real-time discussions
- Follow the project on [Twitter](https://twitter.com/flaskify) for updates
- Subscribe to our [newsletter](https://flaskify.dev/newsletter) for major announcements

---

Thank you for contributing to Flaskify! Your effort helps make this project better for everyone. 🙏