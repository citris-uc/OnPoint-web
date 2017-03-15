class Cards
  def initialize(uid, date)
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

  # Return {
  # "-KeGUkxsE2zevz6JA2VC" => {
  #   {
  #     "action_type" => "action",
  #     "object_id"   => "-Ke0uosmH7rKTUYKAqO_",
  #     "object_type" => "medication_schedule",
  #     "shown_at"    => "2017-03-02T16:08:27.654-08:00"
  #   },
  #   ...,
  #   {}
  # }
  def get
    self.data = self.firebase.get("patients/#{self.uid}/cards/#{self.date.strftime("%F")}").body
    return self.data
  end

  def add(card_hash)
    return self.firebase.push("patients/#{self.uid}/cards/#{self.date.strftime("%F")}", card_hash)
  end

  #----------------------------------------------------------------------------

  def destroy
    date = self.date.beginning_of_day
    [date, date + 1.day, date + 2.days, date + 3.days].each do |d|
      self.firebase.delete("patients/#{self.uid}/cards/#{d.strftime("%F")}")
    end
  end

  #----------------------------------------------------------------------------

  def appointment_cards_between(start_date, end_date)
    date = start_date

    appt_cards = []
    while (date < end_date.end_of_day)
      cards = Cards.new(self.uid, date)
      cards.get()

      if cards.data
        appt_cards += cards.data.to_a.find_all {|c| c[1]["object_type"] == "appointment"}
      end

      date  += 1.day
    end

    return appt_cards
  end

  # def self.find_by_uid_and_date(uid, date_string)
  #   firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
  #   return firebase.get("patients/#{uid}/cards/#{date_string}").body
  # end

  #----------------------------------------------------------------------------

  def generate_from_medication_schedule_if_none
    if self.data.blank? || self.data.to_a.find {|c| c[1]["object_type"] == "medication_schedule"}.blank?
      self.generate_from_medication_schedule()
    end
  end

  def generate_from_medication_schedule
    self.get()

    ms = MedicationSchedule.new(uid)
    ms.get()

    ms.data.to_a.each do |slot|
      object_id = slot[0]
      slot_hash = slot[1]

      # Skip this slot if today's cards already have it.
      next if self.data && self.data.values.find {|v| v["object_id"] == object_id}

      # Skip this slot if today's date doesn't match when it should be displayed.
      week_day = self.date.wday
      next unless slot_hash["days"][week_day] == true

      # At this point, there is no card with this slot AND it matches the weekday.
      # Let's create the card.
      card_hash = {}
      card_hash[:object_type] = "medication_schedule"
      card_hash[:object_id]   = object_id
      card_hash[:medication_schedule] = slot_hash
      self.add(card_hash)
    end
  end

  #----------------------------------------------------------------------------

end
