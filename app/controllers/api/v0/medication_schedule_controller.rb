class API::V0::MedicationScheduleController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # POST /api/v0/medication_schedule

  # schedule = [
  #   {
  #     time: "08:00",
  #     name: "Morning",
  #     days: [true, true, true, true, true, true, true], //array descirbing days of week to do this action
  #     medications: ["Lasix", "Toprol XL", "Zestril", "Coumadin", "Riomet"]
  #   },
  #   {
  #     time: "13:00",
  #     name: "Afternoon",
  #     days: [true, true, true, true, true, true, true], //array descirbing days of week to do this action,
  #     medications: ["Lasix", "Toprol XL", "Zestril", "Riomet"]
  #   },
  #   {
  #     time: "19:00",
  #     name: "Evening",
  #     days: [true, true, true, true, true, true, true], //array descirbing days of week to do this action,
  #     medications: ["Lipitor"]
  #   }
  # ]
  # {"-K_1l5MScJdm1tLxwpWr"=>{"days"=>[true, true, true, true, true, true, true], "medications"=>["Lasix", "Toprol XL", "Zestril", "Coumadin", "Riomet"], "slot"=>"Morning", "time"=>"08:00"}, "-K_1l5MWAI_ppaHQiKdM"=>{"days"=>[true, true, true, true, true, true, true], "medications"=>["Lasix", "Toprol XL", "Zestril", "Riomet"], "slot"=>"Afternoon", "time"=>"13:00"}, "-K_1l5M_bVZP4sOZD4Fy"=>{"days"=>[true, true, true, true, true, true, true], "medications"=>["Lipitor"], "slot"=>"Evening", "time"=>"19:00"}}
  def create

    existing_schedules = MedicationSchedule.find_by_uid(@uid).to_a.map {|slot| {:id => slot[0], :data => slot[1]} }
    MedicationSchedule.default_schedule.each do |slot|
      puts "slot: #{slot.inspect}"
      ids = Medication.find_ids_by_names(@uid, slot["medications"])
      puts "ids: #{ids}\n\n\n"

      # raise "existing_schedules: #{existing_schedules.inspect}"
      matching_schedule = existing_schedules.find {|s| puts "s: #{s}"; s[:data]["slot"].downcase == slot["name"].downcase && s[:data]["time"] == slot["time"]}
      if matching_schedule.present?
        # Overwrite the medications already stored.
        data = matching_schedule[:data]
        data["medications"] = ids
        MedicationSchedule.update(@uid, matching_schedule[:id], data)
      else
        data = slot
        data["slot"]        = data["name"]
        data["medications"] = ids
        MedicationSchedule.save(@uid, data)
      end
    end

  end

end
