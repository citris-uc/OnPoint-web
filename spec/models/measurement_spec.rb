require "rails_helper"

describe Measurement do
  before(:each) do
    @uid = "4ff98c60-5be5-4274-b5ce-ad9dde33e5d9"
  end

  #----------------------------------------------------------------------------

  it "returns a schedule" do
    m = Measurement.new(@uid)
    m.get()
    expect(m.schedule).not_to eq(nil)
  end

  it "creates a card" do
    m = Measurement.new(@uid)
    m.generate_card()

    cards = Cards.new(@uid, Time.zone.now)
    cards.get()
    expect(cards.data["measurement"]).not_to eq(nil)
  end
end
