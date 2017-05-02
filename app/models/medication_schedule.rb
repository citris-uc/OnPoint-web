class MedicationSchedule
  def initialize(uid)
    @uid  = uid
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "data")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  def get
    self.data = self.firebase.get("patients/#{self.uid}/medication_schedule").body
    return self.data
  end

  def self.save(uid, data)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.push("patients/#{uid}/medication_schedule/", data)
  end


  def self.default_schedule
    schedule = [
      {
        time: "08:00",
        name: "Morning",
        days: [true, true, true, true, true, true, true], # array descirbing days of week to do this action
      }.with_indifferent_access,
      {
        time: "13:00",
        name: "Afternoon",
        days: [true, true, true, true, true, true, true], # array descirbing days of week to do this action,
      }.with_indifferent_access,
      {
        time: "19:00",
        name: "Evening",
        days: [true, true, true, true, true, true, true], # array descirbing days of week to do this action,
      }.with_indifferent_access
    ]

    return schedule
  end

  #----------------------------------------------------------------------------

  def self.generate_default_schedule(uid)
    self.default_schedule.each do |slot|
      MedicationSchedule.save(uid, slot.merge("medications" => []))
    end
  end

  #----------------------------------------------------------------------------

  def generate_card(date = Time.zone.now)
    self.get()

    p     = Patient.new(self.uid)
    cards = p.cards_for_date(date)

    self.data.each do |med_schedule_id, med_schedule_data|
      # Skip if this med_schedule_id is there already.
      next if cards && cards[med_schedule_id].present?

      # Do not generate a card if there are no medications.
      next if med_schedule_data["medications"].blank?

      # Skip this slot if today's date doesn't match when it should be displayed.
      next unless med_schedule_data["days"][date.wday] == true

      # At this point, there is no card with this slot AND it matches the weekday.
      # Let's create the card.
      card_hash = {:object_id => med_schedule_id, :object_type => "medication_schedule", :medication_schedule => med_schedule_data}
      c = Card.new(self.uid, date, med_schedule_id)
      c.create(card_hash)
    end
  end

  #----------------------------------------------------------------------------


end
