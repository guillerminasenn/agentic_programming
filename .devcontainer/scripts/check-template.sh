#!/usr/bin/env bash
cd "$(dirname "$0")/../.." || exit 0

current=$(cd .devcontainer_template && find . -type f ! -path '*/__pycache__/*' -printf '%P\n' \
          | LC_ALL=C sort | xargs -d '\n' sha256sum)

if [ "$current" != "$(cat .devcontainer/template.sha256 2>/dev/null)" ]; then
  echo "Dev container: .devcontainer_template has changed since .devcontainer was made" \
       "from it. Check the changes with git diff, run update.py on the host and rebuild" \
       "the container (see .devcontainer_template/README.md)." >&2
fi
exit 0