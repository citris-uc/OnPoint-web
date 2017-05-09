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
    MedicationSchedule.generate_default_schedule(@uid)
  end

  #----------------------------------------------------------------------------
  # PUT /api/v0/medication_schedule/remove_medication

  def remove_medication
    # raise "params: #{params.inspect}"
    # @drug = Drug.new(params[:rxcui])

    med_id = params[:medication]["$id"]
    # Drug.destroy(@uid, )

    # Iterate over all the schedules, removing the specific drug
    @schedule = MedicationSchedule.new(@uid)
    @schedule.get()
    puts "@schedule.data: #{@schedule.data.inspect}\n\n\n"
    @schedule.data.to_a.each do |data|
      schedule_id = data[0]
      hash        = data[1]

      if hash["medications"].present?
        new_medications = hash["medications"].find_all {|id, med_data| med_data["id"] != med_id}
        puts "Just removed med_id = #{med_id} from hash[medications] = #{hash["medications"]}"

        hash["medications"] = new_medications.to_h
        slot = Slot.new(@uid, schedule_id)
        slot.update(hash)
      end
    end


  end

end
