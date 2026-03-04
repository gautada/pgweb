#!/bin/sh
#
# Health check: verifies pgweb is responding on port 8080.
# Uses curl with a 5-second timeout to probe the HTTP endpoint.
# pgweb returns HTTP 200 even without a database (shows login form).
# Returns 0 if pgweb responds, non-zero otherwise.

if curl -sf --max-time 5 http://localhost:8080 > /dev/null 2>&1; then
  echo "pgweb-running: pgweb is responding on port 8080"
  exit 0
fi

echo "pgweb-running: pgweb is not responding on port 8080"
exit 1
