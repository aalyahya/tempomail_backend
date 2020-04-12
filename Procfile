release: bundle exec rails db:migrate data:migrate tmp:cache:clear
web: bundle exec puma -C config/puma.rb
worker: bundle exec rake jobs:work
log: tail -f log/development.log
