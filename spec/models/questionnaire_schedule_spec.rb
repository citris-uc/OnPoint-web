require "rails_helper"

describe QuestionnaireSchedule do
  before(:each) do
    @uid = "4ff98c60-5be5-4274-b5ce-ad9dde33e5d9"
  end

  #----------------------------------------------------------------------------

  it "returns data" do
    m = QuestionnaireSchedule.new(@uid)
    m.get()
    expect(m.data).not_to eq(nil)
  end

  it "creates a card" do
    a = QuestionnaireSchedule.new(@uid)
    a.generate_cards()

    cards = Cards.new(@uid, Time.zone.now)
    cards.get()
    expect(cards.data["questionnaire"]["object_type"]).to eq("questionnaire_reminder")
  end
end
