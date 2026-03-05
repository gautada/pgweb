#!/bin/sh
#
# Returns the version of the installed pgweb binary.
# Parses the output of `pgweb --version`.
# Returns non-zero if the version cannot be determined.

VERSION=$(pgweb --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  echo "Failed to determine pgweb version" >&2
  exit 1
fi

printf '%s\n' "$VERSION"
