class API::V0::DrugsController < API::V0::BaseController
  #----------------------------------------------------------------------------
  # GET /api/v0/drugs
  def show
    drugs = []

    rxcuis = Drug.find_rxcuis_by_name(params[:query].downcase.strip)
    if rxcuis.present?
      d = Drug.new(rxcuis[0])
      d.scd = d.find_scd_matches()
      drugs = d.scd
    end

    render :json => drugs, :status => :ok and return
  end

  #----------------------------------------------------------------------------

  def dailymed
    drugs = []
    data = Drug.find_by_query_and_dailymed(params[:query].downcase.strip)
    render :json => {:data => data}, :status => :ok and return
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/drugs/rxcui?rxcui=...
  def rxcui
    @drug = Drug.new(params[:rxcui])
    @drug.get_pill_images_via_rximage()
    @drug.get_fda_information()
  end

  #----------------------------------------------------------------------------
end
