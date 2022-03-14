#!/usr/bin/env bash

commit_hash=$(git rev-parse HEAD)
cd build/html
# heroku git:remote -a $HEROKU_APP_NAME
echo "{}" > composer.json
echo "<?php include_once(\"index.html\"); ?>" > index.php
git add .
git commit -am "$commit_hash"
git push heroku master
