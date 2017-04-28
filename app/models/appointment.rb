class Appointment
  def initialize(uid)
    @uid  = uid
    self.class.send(:attr_accessor, "uid")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  def schedule
    self.schedule = self.firebase.get("patients/#{self.uid}/appointment_schedule").body
    return self.schedule
  end

  def generate_from_schedule_if_none
    if self.schedule.blank?
      self.generate_from_schedule()
    end
  end

  def generate_from_schedule
    self.schedule()

    # (0..6).to_a.each do |wday|
    #   next unless self.schedule["days"][wday] == true
    #
    #   # At this point, there is no card with this slot AND it matches the weekday.
    #   # Let's create the card.
    #   card_hash               = {}
    #   card_hash[:object_type] = "appointment_schedule"
    #   card_hash[:appointment_schedule] = self.schedule
    #   Cards.create("appointment", card_hash)


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


end
