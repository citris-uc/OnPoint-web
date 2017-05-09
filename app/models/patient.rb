class Patient
  def initialize(uid)
    @uid = uid
    self.class.send(:attr_accessor, "uid")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  #----------------------------------------------------------------------------

  def appointments
    return self.firebase.get("patients/#{self.uid}/appointments").body
  end

  def appointments_for_date(date)
    return self.firebase.get("patients/#{self.uid}/appointments/#{date.strftime("%F")}").body
  end

  def cards
    return self.firebase.get("patients/#{self.uid}/cards").body
  end

  def cards_for_date(date)
    return self.firebase.get("patients/#{self.uid}/cards/#{date.strftime("%F")}").body
  end

  #----------------------------------------------------------------------------

  def generate_cards_for_date(date = Time.zone.now)
    

    ms = MedicationSchedule.new(self.uid)
    ms.generate_card(date)

    m = MeasurementSchedule.new(self.uid)
    m.generate_card(date)

    appt = Appointment.new(self.uid)
    appt.generate_cards(date)

    quiz = QuestionnaireSchedule.new(self.uid)
    quiz.generate_card(date)
  end

  #----------------------------------------------------------------------------

  def self.all
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/").body
  end

  #----------------------------------------------------------------------------

end
