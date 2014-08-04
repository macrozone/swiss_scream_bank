#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MONGO_URL=mongodb://localhost/swiss_scream_bank
export ROOT_URL=http://swiss-scream-bank.macrozone.ch
export PORT=8130
export METEOR_SETTINGS=$(cat settings.prod.json)
forever start $DIR/bundle/main.js
