class API::V0::MedicationHistoryController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # GET /api/v0/medication_history?schedule_id=...

  def show
    date_string = Time.zone.now.strftime("%F") #Card.format_date(Time.zone.now)

    if params["schedule_id"].blank?
      raise API::V0::Error.new("You need to supply schedule ID", 403) and return
    end

    @history = MedicationHistory.find_all_by_date_and_schedule_id(@uid, date_string, params["schedule_id"])
  end
end
