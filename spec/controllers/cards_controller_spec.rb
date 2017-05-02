require "rails_helper"

describe API::V0::CardsController do
  render_views

  def http_login
    request.env['HTTP_AUTHORIZATION'] = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRlc3RAbWFpbGluYXRvci5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlhdCI6MTQ5MzI0NDU3MiwidiI6MCwiZCI6eyJwcm92aWRlciI6InBhc3N3b3JkIiwidWlkIjoiNGZmOThjNjAtNWJlNS00Mjc0LWI1Y2UtYWQ5ZGRlMzNlNWQ5In19.rCMRYFrXmDnICLOgGmxppaxmiweHAtocab_HWGK9x7I"
  end

  before(:each) do
    http_login()

    # Email: test@mailinator.com
    @uid = "4ff98c60-5be5-4274-b5ce-ad9dde33e5d9"
  end

  #----------------------------------------------------------------------------

  it "generates card with proper key and values" do
    get :index, :params => {}, :format => :json
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

  #----------------------------------------------------------------------------

  it "destroys upcoming cards" do
    delete :destroy_upcoming, :params => {}, :format => :json
    cards = Card.new(@uid, Time.zone.now)
    cards.get()
    expect(cards.data).to eq(nil)
  end

  #----------------------------------------------------------------------------

  it "destroys appointment card" do
    appt = Appointment.new(@uid)
    appt.generate_cards

    p         = Patient.new(self.uid)
    appts     = p.appointments
    appt_id   = appts.keys[0]
    appt_date = appts[appt_id]["date"]

    delete :destroy_appointment, :params => {:appointment_date => Time.zone.now.strftime("%F"), :appointment_id => appt_id}, :format => :json
    cards = Card.new(@uid, Time.zone.now)
    cards.get()

    appt_id = appt.get_all().keys[0]
    expect(cards.data[appt_id]).to eq(nil)
  end

  #----------------------------------------------------------------------------
end
