# encoding: utf-8

# Iterates over all cards, setting missed_at or completed_at
class CardGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true

  def perform
    # Only run this on Sunday
    week_day = Time.zone.now.wday
    return unless week_day == 1

    patients = Patient.all
    patients.each do |uid, data|
      cards = Cards.new(uid, Time.zone.now.strftime("%F"))
      cards.get()

      cards.data.to_a.each do |card_id, card_data|
        next unless card_data["object_type"] == "questionnaire_reminder"

        # At this point, we don't have a Questionnaire Reminder. Let's create one.
        card_hash = {}
        card_hash[:object_type]         = "questionnaire_reminder"
        cards.add(card_hash)
      end
    end
  end
end
