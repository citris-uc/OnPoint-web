class API::V0::MedicationsController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # PUT /api/v0/medications/decide

  def decide
    history = MedicationHistory.create_or_update(@uid, params["medication_id"], params["schedule_id"], params["choice"])
    if history
      render :json => {}, :status => :ok and return
    end
  end

end
