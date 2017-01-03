class Medication < ActiveRecord::Base
  # uid = 1dae2ad5-9d3c-407c-9d8e-6f3796f0a2ec
  def self.find_by_uid(uid)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/medications").body
  end

  def self.find_by_uid_and_name(uid, name)
    medications = self.find_by_uid(uid)
    el = medications.find {|id, data| data["trade_name"].strip.downcase == name.strip.downcase}
    return {} if el.blank?
    return {:id => el[0], :data => el[1]}
  end
end
