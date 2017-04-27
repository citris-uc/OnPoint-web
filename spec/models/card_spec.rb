require "rails_helper"

describe Card do
  before(:each) do
    @uid = "4ff98c60-5be5-4274-b5ce-ad9dde33e5d9"
  end

  #----------------------------------------------------------------------------

  it "properly calculates completeness" do
    card = Card.new(@uid, Time.zone.parse("2017-04-26"), "-KihJpdfORCqFnRGP4Ik")
    card.calculate_status()
    # expect(card)
  end
end
