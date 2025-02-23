import os
import sys
sys.path.insert(0, os.path.abspath('..'))

project = 'Flaskify'
copyright = '2025'
author = 'DonArtkins'

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx_rtd_theme',
    'sphinx.ext.viewcode',
    'sphinx_autodoc_typehints',
    'sphinx_copybutton',
    'myst_parser'
]

html_theme = 'sphinx_rtd_theme'