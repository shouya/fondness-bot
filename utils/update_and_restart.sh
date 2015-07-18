#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

GIT_WORK_TREE=/var/www/

git reset --hard

bundle install
bash ./utils/migrate.sh
