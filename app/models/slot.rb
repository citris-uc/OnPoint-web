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
    self.data = self.firebase.get("patients/#{uid}/medication_schedule/#{self.id}/").body
    return self.data
  end
end
