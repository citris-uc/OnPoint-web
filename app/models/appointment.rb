class Appointment
  def initialize(uid, date = nil)
    @uid  = uid
    @date = date
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "date")
    self.class.send(:attr_accessor, "data")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  #----------------------------------------------------------------------------

  def create(data)
    return self.firebase.add("patients/#{self.uid}/appointments/#{self.date.strftime("%F")}", data)
  end

  #----------------------------------------------------------------------------

  def generate_cards(date = Time.zone.now)
    p            = Patient.new(self.uid)
    appointments = p.appointments
    return if appointments.blank?

    # Create  card for this date only if there is an appointment for this date.
    if appts_for_date = appointments[date.strftime("%F")]
      appts_for_date.each do |appt_id, appt_hash|
        card_hash = {:object_type => "appointment_reminder", :object_id => appt_id, :appointment => appt_hash}
        card = Card.new(self.uid, date, appt_id)
        card.create(card_hash)
      end
    end
  end

  #----------------------------------------------------------------------------

end
