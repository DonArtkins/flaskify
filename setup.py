from setuptools import setup, find_packages

setup(
    name="flaskify",
    version="1.0.0",
    packages=find_packages(),
    author="Don Artkins",
    description="Flask-based web framework with version management and interactive CLI",
    entry_points={
        'console_scripts': [
            'flaskify=flaskify.cli:cli',
        ],
    },
    install_requires=[
        'click>=8.0.0',
        'inquirer>=2.9.0',
        'colorama>=0.4.4',
    ],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
    ],
    python_requires='>=3.8',
)