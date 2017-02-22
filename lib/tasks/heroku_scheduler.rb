# These tasks run in our Heroku Scheduler
# See: https://devcenter.heroku.com/articles/scheduler
namespace :heroku_scheduler do
  # This will take events completed in the past 3 days, and calculates an
  # assessment aggregate report for them.
  desc "Creates daily assessment reports"
  task :generate_daily_cards => [:environment] do
    DailyCardsWorker.perform_async()
  end
end
