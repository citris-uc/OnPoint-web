require "rails_helper"

describe Appointment do
  before(:each) do
    @uid = "4ff98c60-5be5-4274-b5ce-ad9dde33e5d9"
  end

  it "returns data" do
    m = Appointment.new(@uid)
    m.get()
    expect(m.data).not_to eq(nil)
  end

  it "generates 2 appointment cards if there are 2 appointments for a date" do
    m = Appointment.new(@uid, Time.zone.now)
    m.create({date: Time.zone.now.strftime("%F"), note: "TEST", time: "10:00", title: "Test with Dr. Test "})

    m = Appointment.new(@uid, Time.zone.now)
    m.create({date: Time.zone.now.strftime("%F"), note: "TEST 2", time: "11:00", title: "Test with Dr. Test 2"})

    patient = Patient.new(@uid)
    appts = patient.appointments_for_date(Time.zone.now).keys

    appt = Appointment.new(@uid)
    appt.generate_cards
    cards = patient.cards_for_date(Time.zone.now)
    keys.each do |appt_id|
      expect(cards[appt_id]).not_to eq(nil)
    end
  end
end
