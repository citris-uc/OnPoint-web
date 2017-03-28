# encoding: utf-8

class CardGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true

  def perform
    # Only run this on Sunday
    week_day = Time.zone.now.wday
    return unless week_day == 1

    patients = Patient.all
    patients.each do |uid, data|
      cards = Cards.new(uid, Time.zone.now)
      cards.get()

      card_hash = {:object_type => "questionnaire_reminder"}
      cards.add(card_hash)
    end
  end
end
