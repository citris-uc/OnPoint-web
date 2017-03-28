# encoding: utf-8

# Iterates over all cards, setting missed_at or completed_at
class CardsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true

  def perform
    yesterday = Time.zone.yesterday


    (0..30).to_a.each do |index|
      date = yesterday - index.days

      patients = Patient.all
      patients.each do |uid, data|
        cards = Cards.new(uid, date)
        cards.get()

        cards.data.to_a.each do |card_id, card_data|
          card = Card.new(uid, date, card_id)
          card.calculate_completeness(card_data, date)
        end
      end
    end
  end
end
