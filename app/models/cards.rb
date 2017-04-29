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

  def create(slot_id, card_hash)
    raise "slot_id is not present" if slot_id.blank?

    return self.firebase.set("patients/#{self.uid}/cards/#{self.date.strftime("%F")}/#{slot_id}", card_hash)
  end

  def create_or_update(slot_id, card_hash)
    raise "slot_id is not present" if slot_id.blank?
    return self.firebase.set("patients/#{self.uid}/cards/#{self.date.strftime("%F")}/#{slot_id}", card_hash)
  end

  def destroy
    date = self.date.beginning_of_day
    [date, date + 1.day, date + 2.days, date + 3.days].each do |d|
      self.firebase.delete("patients/#{self.uid}/cards/#{d.strftime("%F")}")
    end
  end


  # def self.find_by_uid_and_date(uid, date_string)
  #   firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
  #   return firebase.get("patients/#{uid}/cards/#{date_string}").body
  # end

  #----------------------------------------------------------------------------

  def generate_from_medication_schedule_if_none
    if self.data.blank? || self.data.find {|slot_id, slot_hash| slot_hash["object_type"] == "medication_schedule"}.blank?
      self.generate_from_medication_schedule()
    end
  end

  def generate_from_medication_schedule
    self.get()

    ms = MedicationSchedule.new(uid)
    ms.get()

    ms.data.each do |slot_id, slot_hash|
      # object_id = slot[0]
      # slot_hash = slot[1]

      next if self.data && self.data[slot_id]

      # Skip this slot if today's date doesn't match when it should be displayed.
      week_day = self.date.wday
      next unless slot_hash["days"][week_day] == true

      # Do not generate a card if there are no medications.
      next if slot_hash["medications"].blank?

      # At this point, there is no card with this slot AND it matches the weekday.
      # Let's create the card.
      card_hash = {}
      card_hash[:object_type] = "medication_schedule"
      card_hash[:object_id]   = slot_id
      card_hash[:medication_schedule] = slot_hash
      self.create(slot_id, card_hash)


      # puts "Looking at slot hash = #{slot_hash}"
      # # Skip this slot if today's cards already have it.
      # next if self.data && self.data.values.find {|v| v["object_id"] == object_id}
      #
      # # Skip this slot if today's date doesn't match when it should be displayed.
      # week_day = self.date.wday
      # next unless slot_hash["days"][week_day] == true
      #
      # # Do not generate a card if there are no medications.
      # next if slot_hash["medications"].blank?
      #
      # # At this point, there is no card with this slot AND it matches the weekday.
      # # Let's create the card.
      # card_hash = {}
      # card_hash[:object_type] = "medication_schedule"
      # card_hash[:object_id]   = object_id
      # card_hash[:medication_schedule] = slot_hash
      # self.add(card_hash)
    end
  end

  #----------------------------------------------------------------------------

end
