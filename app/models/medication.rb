class Medication < ActiveRecord::Base

  # defaultMeds = [
  #   {id: 1, name: "furomeside", trade_name: "Lasix", instructions: "Take twice daily; First in morning and then 6-8 hours later", purpose: "Treats salt and fluid retention and swelling caused by heart failure.", dose: 40, tablets: 1, required: false, img:"lasix.png"},
  #   {id: 2, name: "metoprolol", trade_name: "Toprol XL", instructions: "TODO: Add instructions here", purpose: "Used to treat chest pain (angina), heart failure, and high blood pressure.", dose: 500, tablets: 2, required: true, img:"toprol.png"},
  #   {id: 3, name: "lisinopril", trade_name: "Zestril", instructions: "TODO: Add instructions here", purpose: "Zestril is used to treat high blood pressure (hypertension) or congestive heart failure.", dose: 40, tablets: 3, required: false, img:"zestril.png"},
  #   {id: 4, name: "warfarin", trade_name: "Coumadin", instructions: "Take orally once a day in the morning", purpose: "Treats and prevents blood clots by acting as a blood thinner.", dose: 500, tablets: 4, required: true, img:"coumadin.png"},
  #   {id: 5, name: "losartan", trade_name: "Cozaar", instructions: "TODO: Add instructions here", purpose: "It can treat high blood pressure.", dose: 40, tablets: 5, required: false, img:"cozaar.png"},
  #   {id: 6, name: "metformin", trade_name: "Riomet", instructions: "Take orally, twice daily, with meals", purpose: "Used to treat Type 2 Diabetes.", dose: 40, tablets: 6, required: false, img:"riomet.png"},
  #   {id: 7, name: "statin", trade_name: "Lipitor", instructions: "TODO: Add instructions here", purpose: "It can treat high cholesterol and triglyceride levels.", dose: 40, tablets: 7, required: false, img:"lipitor.png"}
  # ]
  def self.default_medications
    return [
      {id: 1, name: "furomeside", trade_name: "Lasix", instructions: "Take twice daily; First in morning and then 6-8 hours later", purpose: "Treats salt and fluid retention and swelling caused by heart failure.", dose: 40, tablets: 1, required: false, img:"lasix.png"},
      {id: 2, name: "metoprolol", trade_name: "Toprol XL", instructions: "TODO: Add instructions here", purpose: "Used to treat chest pain (angina), heart failure, and high blood pressure.", dose: 500, tablets: 2, required: true, img:"toprol.png"},
      {id: 3, name: "lisinopril", trade_name: "Zestril", instructions: "TODO: Add instructions here", purpose: "Zestril is used to treat high blood pressure (hypertension) or congestive heart failure.", dose: 40, tablets: 3, required: false, img:"zestril.png"},
      {id: 4, name: "warfarin", trade_name: "Coumadin", instructions: "Take orally once a day in the morning", purpose: "Treats and prevents blood clots by acting as a blood thinner.", dose: 500, tablets: 4, required: true, img:"coumadin.png"},
      {id: 5, name: "losartan", trade_name: "Cozaar", instructions: "TODO: Add instructions here", purpose: "It can treat high blood pressure.", dose: 40, tablets: 5, required: false, img:"cozaar.png"},
      {id: 6, name: "metformin", trade_name: "Riomet", instructions: "Take orally, twice daily, with meals", purpose: "Used to treat Type 2 Diabetes.", dose: 40, tablets: 6, required: false, img:"riomet.png"},
      {id: 7, name: "statin", trade_name: "Lipitor", instructions: "TODO: Add instructions here", purpose: "It can treat high cholesterol and triglyceride levels.", dose: 40, tablets: 7, required: false, img:"lipitor.png"}
    ]
  end

  def self.save(uid, data)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    path = "patients/#{uid}/medications/"
    return firebase.push(path, data)
  end

  # uid = 1dae2ad5-9d3c-407c-9d8e-6f3796f0a2ec
  def self.all(uid)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/medications").body
  end

  def self.find_ids_by_names(uid, trade_names)
    trade_names = trade_names.map {|tn| tn.downcase}

    medications = self.all(uid)
    medications.to_a.find_all {|med| trade_names.include?(med[1]["trade_name"].downcase) }.map {|med| med[0]}
  end

  def self.find_by_uid_and_name(uid, name)
    puts "name = #{name}\n\n\n"
    medications = self.all(uid)
    el = medications.find {|id, data| puts "id: #{id}... data: #{data}"; data["trade_name"].strip.downcase == name.strip.downcase}
    return {} if el.blank?
    return {:id => el[0], :data => el[1]}
  end

  # def self.segment_by_state(uid, schedule_id, med_names, date_key)
  #   needs_decision = []
  #   skipped        = []
  #   completed      = []
  #
  #
  #   history     = MedicationHistory.find_all_by_date_and_schedule_id(uid, date_key, schedule_id)
  #   medications = Medication.all(uid)
  #   med_names ||= []
  #   meds_for_schedule = medications.find_all {|k, data| puts "data: #{data}"; med_names.include?(data["trade_name"])}.map {|el| el[1]}
  #   if history.blank?
  #     return {
  #       :unfinished => meds_for_schedule,
  #       :skipped    => [],
  #       :done       => []
  #     }
  #   end
  #
  #
  #   history.each do |hist|
  #     data = hist[1]
  #     if data["taken_at"].present?
  #       completed << data["medication_id"]
  #     elsif data["skipped_at"].present?
  #       skipped << data["medication_id"]
  #     end
  #   end
  #
  #   done = completed.map {|med| medications[med]}
  #   skip = skipped.map {|med| medications[med]}
  #   needs_decision = meds_for_schedule - done - skip
  #   # raise "done: #{done}"
  #   # raise "meds_for_schedule: #{meds_for_schedule}"
  #   # raise "needs_decision: #{needs_decision}"
  #
  #
  #   return {
  #     :unfinished => needs_decision,
  #     :skipped    => skip,
  #     :done       => done,
  #   }
  # end
end
