#!/bin/sh

rm tmp/pids/server.pid
bundle exec rails db:create db:migrate

if [ -z ${WEBHOOK_URL} ]; then
  bundle exec rake start_polling
else
  bundle exec rails server -b 0.0.0.0
fi
