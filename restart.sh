#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MONGO_URL=mongodb://localhost/swiss_scream_bank
export ROOT_URL=http://www.swissscreamscape.org
export PORT=8130
export METEOR_SETTINGS=$(cat settings.prod.json)
forever restart $DIR/bundle/main.js
