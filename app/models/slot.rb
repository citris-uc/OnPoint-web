class Slot
  def initialize(uid, id)
    @uid  = uid
    @id  = id
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "id")
    self.class.send(:attr_accessor, "data")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  def get
    self.data = self.firebase.get("patients/#{self.uid}/medication_schedule/#{self.id}/").body
    return self.data
  end

  # NOTE: Updates, but does not delete ommitted children.
  def update(data)
    return self.firebase.update("patients/#{self.uid}/medication_schedule/#{self.id}/", data)
  end

  def past?
    return Time.zone.now > Time.zone.parse(self.data["time"]) + 2.hours
  end
end
