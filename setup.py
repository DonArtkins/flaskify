from setuptools import setup, find_packages

setup(
    name="flaskify",
    version="1.0.0",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "click>=8.0.0",
        "Flask>=2.0.0",
        "inquirer>=2.7.0",
        "colorama>=0.4.4",
    ],
    entry_points={
        'console_scripts': [
            'flaskify=flaskify.cli:cli',
        ],
    },
    package_data={
        'flaskify': ['templates/**/*'],
    },
    python_requires='>=3.7',
)