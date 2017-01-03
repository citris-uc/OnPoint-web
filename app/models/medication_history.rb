class MedicationHistory < ActiveRecord::Base
  # uid = 1dae2ad5-9d3c-407c-9d8e-6f3796f0a2ec
  def self.find_by_uid(uid)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/medication_histories").body
  end


  def self.find_by_uid_and_date(uid, date_string)
    histories = self.find_by_uid(uid)
    match = histories.find {|key, value| key == date_string}
    return {} if match.blank?
    return {:id => match[0], :data => match[1]}
  end
end
