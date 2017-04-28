class Measurement
  def initialize(uid)
    @uid  = uid
    self.class.send(:attr_accessor, "uid")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    self.class.send(:attr_accessor, "schedule")

    return self
  end

  def get
    self.schedule = self.firebase.get("patients/#{self.uid}/measurement_schedule").body
    return self.schedule
  end

  def generate_card
    self.get()
    return if self.schedule.blank?

    (0..6).to_a.each do |wday|
      next unless self.schedule["days"][wday] == true

      # At this point, there is no card with this slot AND it matches the weekday.
      # Let's create the card.
      card_hash               = {}
      card_hash[:object_type] = "measurement_schedule"
      card_hash[:measurement_schedule] = self.schedule

      cards = Cards.new(self.uid, Time.zone.now)
      cards.create_or_update("measurement", card_hash)
    end
  end
end
