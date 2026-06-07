#!/bin/bash
# NetClientX Chromium Wrapper
# Forwards execution to the unified installer netclientx.sh

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
exec "$SCRIPT_DIR/netclientx.sh" chromium "$@"
