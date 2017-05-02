require "rails_helper"

describe Patient do
  before(:each) do
    @uid = "4ff98c60-5be5-4274-b5ce-ad9dde33e5d9"
  end

  it "generates cards" do
    p = Patient.new(@uid)
    p.generate_cards_for_date

    cards = Card.new(@uid, Time.zone.now)
    cards.get()

    # ID of card = ID of the medication schedule.
    card = cards.data.find {|k,v| v["object_type"] == "medication_schedule"}
    expect(card[0]).to eq(card[1]["object_id"])

    # ID of card = ID of appointment.
    card = cards.data.find {|k,v| v["object_type"] == "appointment_reminder"}
    expect(card[0]).to eq(card[1]["object_id"])

    # ID of card = 'questionnaire'.
    card = cards.data.find {|k,v| k == "questionnaire"}
    expect(card[1]["object_type"]).to eq("questionnaire_reminder")
  end
end
