web:    bundle exec puma -C config/puma.rb

# See: https://github.com/mperham/sidekiq/wiki/Active-Job#action-mailer
# on why we start the mailers queue.
worker: bundle exec sidekiq -c 10 -q default
