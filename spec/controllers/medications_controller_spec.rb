require "rails_helper"

describe API::V0::MedicationsController do
  render_views

  let(:medication) {
    {"$id"=>"-KigJBv2NeC3FhXwuC8s", "$priority"=>nil, "administration"=>"By mouth", "amount"=>"", "delivery"=>"", "dosage"=>1, "frequency"=>"Daily", "name"=>"Losartan Potassium 100 MG Oral Tablet", "nickname"=>"Losartan", "rxcui"=>"979480", "units"=>"tablets"}
  }

  def http_login
    request.env['HTTP_AUTHORIZATION'] = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRlc3RAbWFpbGluYXRvci5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlhdCI6MTQ5MzI0NDU3MiwidiI6MCwiZCI6eyJwcm92aWRlciI6InBhc3N3b3JkIiwidWlkIjoiNGZmOThjNjAtNWJlNS00Mjc0LWI1Y2UtYWQ5ZGRlMzNlNWQ5In19.rCMRYFrXmDnICLOgGmxppaxmiweHAtocab_HWGK9x7I"
  end

  before(:each) do
    http_login()

    # Email: test@mailinator.com
    @uid = "4ff98c60-5be5-4274-b5ce-ad9dde33e5d9"
  end

  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------

  describe "Making a decision" do
    before(:each) do
      ms = MedicationSchedule.new(@uid)
      ms.get()


      @slot_id       = ms.data.find {|k,v| v["medications"].present?}[0]
    end

    # Started PUT "/api/v0/medications/decide" for 127.0.0.1 at 2017-04-26 15:13:11 -0700
    # Processing by API::V0::MedicationsController#decide as JSON
    #   Parameters: {"medication_id"=>"-KigJBv2NeC3FhXwuC8s", "schedule_id"=>"-KigJCI86z4zFviWuuTe", "choice"=>"take", "medication"=>{"medication_id"=>"-KigJBv2NeC3FhXwuC8s", "schedule_id"=>"-KigJCI86z4zFviWuuTe", "choice"=>"take"}}
    # DEPRECATION WARNING: env is deprecated and will be removed from Rails 5.1 (called from identify_uid at /opt/OnPoint-web/app/controllers/api/v0/base_controller.rb:3)
    # Completed 200 OK in 757ms (Views: 1.3ms | ActiveRecord: 0.0ms)
    it "records a skip" do
      put :decide, :params => {:medication => medication, :schedule_id => @slot_id, :choice => "skip"}
      history = MedicationHistory.new(@uid, Time.zone.now, @slot_id)
      history.get()
      expect( history.data[medication["$id"]]["skipped_at"] ).not_to eq(nil)
    end

    it "records a take" do
      put :decide, :params => {:medication => medication, :schedule_id => @slot_id, :choice => "take"}
      history = MedicationHistory.new(@uid, Time.zone.now, @slot_id)
      history.get()
      expect( history.data[medication["$id"]]["taken_at"] ).not_to eq(nil)
    end

    it "updates the corresponding card" do
      put :decide, :params => {:medication => medication, :schedule_id => @slot_id, :choice => "take"}
      history = MedicationHistory.new(@uid, Time.zone.now, @slot_id)

      slot = Card.new(@uid, Time.zone.now, @slot_id)
      slot.get()
      expect( slot.data["status"] ).not_to eq(nil)
    end
  end

  #----------------------------------------------------------------------------

  describe "Making a decision for all" do
    before(:each) do
      # 2 meds

      ms = MedicationSchedule.new(@uid)
      ms.get()

      slot      = ms.data.find {|k,v| v["medications"].present? && v["medications"].length > 1}
      @slot_id  = slot[0]
      @med1, @med2     = slot[1]["medications"].keys
    end

    # Started PUT "/api/v0/medications/decide" for 127.0.0.1 at 2017-04-26 15:13:11 -0700
    # Processing by API::V0::MedicationsController#decide as JSON
    it "records a skip" do
      put :decide_all, :params => {:schedule_id => @slot_id, :choice => "skip"}
      history = MedicationHistory.new(@uid, Time.zone.now, @slot_id)
      history.get()
      expect( history.data[@med1]["skipped_at"] ).not_to eq(nil)
      expect( history.data[@med2]["skipped_at"] ).not_to eq(nil)
    end

    it "records a take" do
      put :decide_all, :params => {:schedule_id => @slot_id, :choice => "take"}
      history = MedicationHistory.new(@uid, Time.zone.now, @slot_id)
      history.get()
      expect( history.data[@med1]["taken_at"] ).not_to eq(nil)
      expect( history.data[@med2]["taken_at"] ).not_to eq(nil)
    end

    it "updates the corresponding card" do
      put :decide_all, :params => {:medication => medication, :schedule_id => @slot_id, :choice => "skip"}
      history = MedicationHistory.new(@uid, Time.zone.now, @slot_id)

      slot = Card.new(@uid, @slot_id)
      slot.get()
      expect( slot.data["status"] ).not_to eq(nil)
    end
  end

end
