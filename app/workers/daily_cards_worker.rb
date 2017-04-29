# encoding: utf-8

class DailyCardsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true

  def perform
    Patient.all.each do |uid, data|
      patient = Patient.new(uid)
      patient.generate_cards_for_date(Time.zone.today)
      patient.generate_cards_for_date(Time.zone.tomorrow)
    end
  end
end
