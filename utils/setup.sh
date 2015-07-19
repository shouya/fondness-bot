#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

bundle install
bundle exec bin/start.rb
