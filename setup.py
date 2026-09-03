#!/usr/bin/env python3
import re
from setuptools import setup

with open("suplemon/main.py", encoding="utf-8") as f:
    version = re.search(r'^__version__\s*=\s*"([^"]*)"', f.read(), re.M).group(1)

with open("README.md", encoding="utf-8") as f:
    long_description = f.read()

files = ["config/*.json", "themes/*", "modules/*.py", "linelight/*.py"]

# Published as "suplemon-editor" rather than "suplemon", which belongs to the
# original author on PyPI, and rather than "se", which is already a stream
# editor there. The installed commands are still "suplemon" and "se".
setup(name="suplemon-editor",
      version=version,
      description="Console text editor with multi cursor support. Maintained fork of Suplemon.",
      long_description=long_description,
      long_description_content_type="text/markdown",
      # Richard Lewis wrote Suplemon; this fork only maintains it.
      author="Richard Lewis",
      author_email="richrd.lewis@gmail.com",
      maintainer="leancode",
      url="https://github.com/leancode/suplemon/",
      project_urls={
          "Original project": "https://github.com/richrd/suplemon/",
          "Changelog": "https://github.com/leancode/suplemon/blob/master/CHANGELOG.md",
          "Issues": "https://github.com/leancode/suplemon/issues",
      },
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
          "console_scripts": [
              "suplemon=suplemon.cli:main",
              # Short form: SupLemon Editor. Note that a separate "se" package
              # exists on PyPI, so installing both gives whichever landed last.
              "se=suplemon.cli:main",
          ]
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
