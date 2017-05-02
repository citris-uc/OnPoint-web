class MeasurementSchedule
  def initialize(uid)
    @uid  = uid
    self.class.send(:attr_accessor, "uid")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")
    self.class.send(:attr_accessor, "schedule")

    return self
  end

  #----------------------------------------------------------------------------

  def get
    self.schedule = self.firebase.get("patients/#{self.uid}/measurement_schedule").body
    return self.schedule
  end

  #----------------------------------------------------------------------------

  def generate_card(date = Time.zone.now)
    self.get()
    return if self.schedule.blank?

    p     = Patient.new(self.uid)
    cards = p.cards_for_date(date)


    self.schedule.each do |meas_schedule_id, meas_schedule_data|
      # Skip if this med_schedule_id is there already.
      next if cards && cards[meas_schedule_id].present?

      # Skip this slot if today's date doesn't match when it should be displayed.
      next if meas_schedule_data["days"][date.wday] == false

      # At this point, there is no card with this slot AND it matches the weekday.
      # Let's create the card.
      card_hash = {:object_id => meas_schedule_id, :object_type => "measurement_reminder", :measurement_reminder => meas_schedule_data}
      c = Card.new(self.uid, date, meas_schedule_id)
      c.create(card_hash)
    end
  end

  #----------------------------------------------------------------------------

end
