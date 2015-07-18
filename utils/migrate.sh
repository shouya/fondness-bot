#!/bin/bash

MIGRATION_DIR=migrations
DB_FILE=data/db

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

bundle exec sequel -m $MIGRATION_DIR $DB_FILE
