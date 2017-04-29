class Patient
  def initialize(uid)
    @uid = uid
    self.class.send(:attr_accessor, "uid")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  #----------------------------------------------------------------------------

  def generate_cards_for_date(date = Time.zone.now)
    ms = MedicationSchedule.new(self.uid)
    ms.generate_card(d)

    m = Measurement.new(self.uid)
    m.generate_card(date)

    appt = Appointment.new(self.uid)
    appt.generate_card(d)

    quiz = Questionnaire.new(self.uid)
    quiz.generate_card(d)
  end

  #----------------------------------------------------------------------------

  def self.all
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/").body
  end

  #----------------------------------------------------------------------------

end
