class QuestionnaireSchedule
  def initialize(uid)
    @uid  = uid
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "schedule")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  def get
    self.schedule = self.firebase.get("patients/#{self.uid}/questionnaire_schedule").body
    return self.schedule
  end

  def generate_card(date = Time.zone.now)
    self.get()
    return if self.schedule.blank?

    (0..6).to_a.each do |wday|
      next unless self.schedule["days"][wday] == true

      card = Card.new(self.uid, date, "questionnaire")
      card.create({:object_type => "questionnaire_reminder"})
    end
  end
end
