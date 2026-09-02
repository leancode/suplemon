#!/usr/bin/env python3
import re
from setuptools import setup

with open("suplemon/main.py", encoding="utf-8") as f:
    version = re.search(r'^__version__\s*=\s*"([^"]*)"', f.read(), re.M).group(1)

with open("README.md", encoding="utf-8") as f:
    long_description = f.read()

files = ["config/*.json", "themes/*", "modules/*.py", "linelight/*.py"]

setup(name="Suplemon",
      version=version,
      description="Console text editor with multi cursor support.",
      long_description=long_description,
      long_description_content_type="text/markdown",
      author="Richard Lewis",
      author_email="richrd.lewis@gmail.com",
      url="https://github.com/richrd/suplemon/",
      license="MIT",
      # config, modules, themes and linelight ship inside the package. modules
      # and themes have no __init__.py because they are loaded by path rather
      # than imported, but setuptools still needs them listed to install them.
      packages=[
          "suplemon",
          "suplemon.linelight",
          "suplemon.config",
          "suplemon.modules",
          "suplemon.themes",
      ],
      package_data={"": files},
      include_package_data=True,
      python_requires=">=3.8",
      install_requires=[
          "pygments",
          "wcwidth"
      ],
      entry_points={
          "console_scripts": ["suplemon=suplemon.cli:main"]
      },
      classifiers=[
          "Development Status :: 4 - Beta",
          "Environment :: Console :: Curses",
          "Intended Audience :: Developers",
          "Operating System :: MacOS",
          "Operating System :: POSIX",
          "Operating System :: Unix",
          "Programming Language :: Python :: 3",
          "Programming Language :: Python :: 3 :: Only",
          "Topic :: Text Editors",
          "Topic :: Utilities",
      ]
      )
