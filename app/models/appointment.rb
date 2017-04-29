class Appointment
  def initialize(uid)
    @uid  = uid
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "data")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  #----------------------------------------------------------------------------

  def get
    self.data = self.firebase.get("patients/#{self.uid}/appointments").body
    return self.data
  end

  #----------------------------------------------------------------------------

  def generate_card(date = Time.zone.now)
    self.get()
    return if self.data.blank?

    if appt_hash = self.data[date.strftime("%F")]
      appt_id = appt_hash.keys[0]

      card_hash = {:object_type => "appointment_reminder", :object_id => appt_id, :appointment => appt_hash[appt_id]}
      card = Card.new(self.uid, date, appt_id)
      card.create(card_hash)
    end
  end

  #----------------------------------------------------------------------------

end
