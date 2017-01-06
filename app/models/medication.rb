class Medication < ActiveRecord::Base
  # uid = 1dae2ad5-9d3c-407c-9d8e-6f3796f0a2ec
  def self.all(uid)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/medications").body
  end

  def self.find_by_uid_and_name(uid, name)
    medications = self.all(uid)
    el = medications.find {|id, data| data["trade_name"].strip.downcase == name.strip.downcase}
    return {} if el.blank?
    return {:id => el[0], :data => el[1]}
  end

  def self.segment_by_state(uid, schedule_id, med_names, date_key)
    needs_decision = []
    skipped        = []
    completed      = []


    history     = MedicationHistory.find_all_by_date_and_schedule_id(uid, date_key, schedule_id)
    medications = Medication.all(uid)
    med_names ||= []
    meds_for_schedule = medications.find_all {|k, data| puts "data: #{data}"; med_names.include?(data["trade_name"])}.map {|el| el[1]}
    if history.blank?
      return {
        :unfinished => meds_for_schedule,
        :skipped    => [],
        :done       => []
      }
    end


    history.each do |hist|
      data = hist[1]
      if data["taken_at"].present?
        completed << data["medication_id"]
      elsif data["skipped_at"].present?
        skipped << data["medication_id"]
      end
    end

    done = completed.map {|med| medications[med]}
    skip = skipped.map {|med| medications[med]}
    needs_decision = meds_for_schedule - done - skip
    # raise "done: #{done}"
    # raise "meds_for_schedule: #{meds_for_schedule}"
    # raise "needs_decision: #{needs_decision}"


    return {
      :unfinished => needs_decision,
      :skipped    => skip,
      :done       => done,
    }
  end
end
