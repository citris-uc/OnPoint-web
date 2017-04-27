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

  it "generates card with schedule id" do
    get :index, :params => {:upcoming => 1}, :format => :json
    cards = Cards.new(@uid, Time.zone.now)
    cards.get()
    card_id = cards.data.keys[0]

    expect(card_id).to eq(cards.data[card_id]["object_id"])
  end

  #----------------------------------------------------------------------------
end
