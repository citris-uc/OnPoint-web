# encoding: utf-8

class DailyCardsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true

  def perform
    patients = Patient.all
    patients.each do |uid, data|
      cards = Cards.new(uid, Time.zone.today)
      cards.get()
      cards.generate_from_medication_schedule_if_none()

      cards = Cards.new(uid, Time.zone.tomorrow)
      cards.get()
      cards.generate_from_medication_schedule_if_none()
    end
  end
end
