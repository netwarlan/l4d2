#!/usr/bin/env bash
set -e

docker build -t ghcr.io/netwarlan/l4d2 "$@" .
