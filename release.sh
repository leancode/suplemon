#!/usr/bin/env bash
# Exit on first error
set -e

# Parse our CLI arguments
version="$1"
publish="no"
if test "$2" = "--publish"; then
  publish="yes"
fi
if test "$version" = ""; then
  echo "Expected a version to be provided to \`release.sh\` but none was provided." 1>&2
  echo "Usage: $0 [version] [--publish]   # e.g. $0 1.0.0" 1>&2
  echo "  --publish also uploads to PyPI. Without it this only tags and pushes." 1>&2
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

# Publishing is opt in. Tagging a release and putting it on PyPI are separate
# decisions, and the default should not be the irreversible one.
if test "$publish" != "yes"; then
  echo
  echo "Tagged and pushed $version. Not published to PyPI."
  echo "Re-run with --publish to upload, once you are sure."
  exit 0
fi

# Refuse to upload under a distribution name that isn't ours. "Suplemon" on
# PyPI belongs to the original author; uploading this fork there would be
# taking over someone else's package.
dist_name=$(python3 -c 'import re; print(re.search(r"name=\"([^\"]+)\"", open("setup.py").read()).group(1))')
case "$(printf '%s' "$dist_name" | tr '[:upper:]' '[:lower:]')" in
  suplemon)
    echo "Refusing to publish: setup.py says name=\"$dist_name\"." 1>&2
    echo "That distribution belongs to the original author on PyPI." 1>&2
    echo "This fork publishes as suplemon-editor." 1>&2
    exit 1 ;;
esac
echo "Publishing as '$dist_name'."

# `setup.py upload` was removed by PyPI in 2018; builds go through `build`
# and uploads through `twine`.
#   pip install build twine
rm -rf dist
python3 -m build
python3 -m twine upload dist/*
