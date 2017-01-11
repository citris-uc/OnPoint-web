class API::V0::DrugsController < API::V0::BaseController
  #----------------------------------------------------------------------------
  # GET /api/v0/drugs
  def show
    matches = Drug.find_by_name(params[:query].downcase.strip)
    rxcuis  = matches.map {|m| m["rxcui"]}

    # For now, to speed up query.
    rxcuis = rxcuis[0..1]

    drugs = []
    rxcuis.each do |rxcui|
      d = Drug.new(rxcui)
      drugs << d.get_all(false)
    end

    render :json => drugs, :status => :ok and return
  end
end
