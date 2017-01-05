class MedicationSchedule < ActiveRecord::Base
  # uid = 1dae2ad5-9d3c-407c-9d8e-6f3796f0a2ec
  def self.find_by_uid(uid)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/medication_schedule").body
  end

  # $scope.findMedicationScheduleForCard = function(card) {
  def self.find_by_card(uid, card)
    schedules = self.find_by_uid(uid)
    return schedules[card["object_id"]]
  end

end
