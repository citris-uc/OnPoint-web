require "rails_helper"

describe MeasurementSchedule do
  before(:each) do
    @uid = "4ff98c60-5be5-4274-b5ce-ad9dde33e5d9"
  end

  it "returns a schedule" do
    m = MeasurementSchedule.new(@uid)
    m.get()
    expect(m.schedule).not_to eq(nil)
  end

  it "creates a card" do
    m = MeasurementSchedule.new(@uid)
    m.generate_card()

    p = Patient.new(@uid)
    cards = p.cards_for_date(Time.zone.now)
    cards.get()

    card = cards.data.find {|k,v| v["object_type"] == "measurement_reminder"}
    expect(card[0]).to eq(card[1]["object_id"])
    expect(card[1]["measurement_reminder"]).not_to eq(nil)
  end
end
