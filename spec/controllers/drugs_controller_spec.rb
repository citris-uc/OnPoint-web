require "rails_helper"

describe API::V0::DrugsController do
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

    drug_names = ["Aspiri", "Fluticasone propionate", "Paracetamol", "Panadol", "Losartan", "Riomet", "Aspirin", "metformin", "Losartan", "coumadin", "warfarin", "lamotrigine", "Omeprazole", "Acetaminophen", "trazodone", "Ibuprofen", "Furosemide", "Estradiol", "Progesterone", "Codeine", "Tylenol", "Tylenol", "Tylenol", "Tylenol", "Tylenol", "Valium", "Losartan", "Aspirin", "riom", "Metformin", "Losartan", "Tylenol", "Valium", "Cozaar", "Paracetamol", "Famatodine", "Pepcid", "Tylenol", "Progesterone", "Estradiol", "Furosemide"]
    num_no_image_result = 0

    drug_names.each do |name|
      # get "http://localhost:5000/api/v0/drugs/?query=#{name}"
      get :show, :params => {:query => name}, :format => :json

      output = JSON.parse(@response.body)
      puts output[0]
    end
  end

  #----------------------------------------------------------------------------
end
