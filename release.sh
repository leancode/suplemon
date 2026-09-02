#!/usr/bin/env bash
# Exit on first error
set -e

# Parse our CLI arguments
version="$1"
if test "$version" = ""; then
  echo "Expected a version to be provided to \`release.sh\` but none was provided." 1>&2
  echo "Usage: $0 [version] # (e.g. $0 1.0.0)" 1>&2
  exit 1
fi

# Bump the version. Done in Python rather than sed -i, whose syntax differs
# between GNU and BSD and silently created backup files on macOS and FreeBSD.
python3 - "$version" <<'PY'
import re
import sys

version = sys.argv[1]
path = "suplemon/main.py"
with open(path, encoding="utf-8") as f:
    data = f.read()
new, count = re.subn(r'^__version__ = "[^"]*"$',
                     '__version__ = "%s"' % version, data, count=1, flags=re.M)
if count != 1:
    sys.exit("Expected to find __version__ in %s but didn't" % path)
with open(path, "w", encoding="utf-8") as f:
    f.write(new)
PY

# Verify our version made it into the file
if ! grep -q "__version__ = \"$version\"" suplemon/main.py; then
  echo "Expected \`__version__\` to be updated but it wasn't" 1>&2
  exit 1
fi

# Commit the change. Only the version bump, not whatever else is in the tree.
git add suplemon/main.py
git commit -m "Release $version"

# Tag the release
git tag "$version"

# Publish the release to GitHub
git push
git push --tags

# Build and publish to PyPI. `setup.py upload` was removed by PyPI in 2018;
# builds go through `build` and uploads through `twine`.
#   pip install build twine
rm -rf dist
python3 -m build
python3 -m twine upload dist/*
