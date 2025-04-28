import os
import sys
sys.path.insert(0, os.path.abspath('..'))

project = 'Flaskify'
copyright = '2025'
author = 'DonArtkins'

# The short X.Y version
version = '1.0'
# The full version, including alpha/beta/rc tags
release = '1.0.0'

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

# Required for EPUB output
epub_show_urls = 'footnote'