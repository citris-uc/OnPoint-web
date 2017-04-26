class API::V0::MedicationsController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # PUT /api/v0/medications/decide

  def decide
    if params["schedule_id"].blank?
      raise API::V0::Error.new("You didn't specify a schedule ID. Please try again.", 403) and return
    end

    if params["medication"].blank?
      raise API::V0::Error.new("You didn't specify a medication. Please try again", 403) and return
    end

    history = MedicationHistory.new(@uid, Time.zone.now, permitted_params["schedule_id"])
    history.decide(permitted_params["medication"], permitted_params["choice"])
    if history
      render :json => {}, :status => :ok and return
    end
  end

  #----------------------------------------------------------------------------
  # PUT /api/v0/medications/decide_all

  def decide_all
    if params["schedule_id"].blank?
      raise API::V0::Error.new("You didn't specify a schedule ID. Please try again.", 403) and return
    end

    history = MedicationHistory.new(@uid, Time.zone.now, permitted_params["schedule_id"])
    history.decide_all(permitted_params["choice"])
    if history
      render :json => {}, :status => :ok and return
    end
  end

  #----------------------------------------------------------------------------
  # POST /api/v0/medications/

  def create
    Medication.default_medications.each do |med|
      medication = Medication.find_by_uid_and_name(@uid, med[:trade_name])
      if medication.blank?
        Medication.save(@uid, med)
      end
    end

  end


  def permitted_params
    params.permit!
  end
end
