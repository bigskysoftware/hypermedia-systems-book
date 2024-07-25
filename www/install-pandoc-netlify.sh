#!/usr/bin/env bash

# https://github.com/edemaine/topp/blob/b6c4f5a53e1e3d54196204bb7b50046d83ae0f47/netlify-pandoc.sh

PANDOC_URL="https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-amd64.deb"

set -o errexit

# We use $DEPLOY_URL to detect the Netlify environment.
if [ -v DEPLOY_URL ]; then
  : ${NETLIFY_BUILD_BASE="/opt/buildhome"}
else
  : ${NETLIFY_BUILD_BASE="$PWD/buildhome"}
fi

NETLIFY_CACHE_DIR="$NETLIFY_BUILD_BASE/cache"
PANDOC_DIR="$NETLIFY_CACHE_DIR/pandoc"
PANDOC_DEB="`basename "$PANDOC_URL"`"
PANDOC_SUCCESS="$NETLIFY_CACHE_DIR/${PANDOC_DEB}-success"
PANDOC_BIN="$PANDOC_DIR/usr/bin"

if [ ! -e "$PANDOC_SUCCESS" ]; then
  curl -L "$PANDOC_URL" -o "$PANDOC_DEB"
  dpkg -x "$PANDOC_DEB" "$PANDOC_DIR"
  touch "$PANDOC_SUCCESS"
fi

export PATH="$PANDOC_BIN:$PATH"
