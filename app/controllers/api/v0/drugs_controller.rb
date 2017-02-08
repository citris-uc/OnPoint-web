class API::V0::DrugsController < API::V0::BaseController
  #----------------------------------------------------------------------------
  # GET /api/v0/drugs
  def show
    drugs = []

    matches = Drug.find_by_name(params[:query].downcase.strip)
    if matches.present?
      rxcuis = matches.map {|m| m["rxcui"]}
      rxcuis.each do |rxcui|
        d = Drug.new(rxcui)
        drugs << d.get_all(false)
      end
    end

    render :json => drugs, :status => :ok and return
  end

  def dailymed
    drugs = []
    data = Drug.find_by_query_and_dailymed(params[:query].downcase.strip)
    render :json => {:data => data}, :status => :ok and return
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/drugs/rxcui?rxcui=...
  def rxcui
    drug = Drug.new(params[:rxcui])
    drug.related()
    drug.get_images()
    render :json => drug, :status => :ok and return
  end

  #----------------------------------------------------------------------------
end
