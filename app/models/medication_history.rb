class MedicationHistory
  #----------------------------------------------------------------------------

  def initialize(uid, date, slot_id = nil)
    @uid     = uid
    @date    = date
    @slot_id = slot_id
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "date")
    self.class.send(:attr_accessor, "slot_id")
    self.class.send(:attr_accessor, "data")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")
    return self
  end

  #----------------------------------------------------------------------------

  def get
    array     = self.firebase.get("patients/#{self.uid}/medication_histories/#{self.date.strftime('%F')}/#{self.slot_id}").body
    self.data = array.to_h
    return self.data
  end

  #----------------------------------------------------------------------------

  def update(medication_id, data)
    raise "medication_id is missing" if medication_id.blank?

    data.reject! {|k,v| k.include?("$")}
    response = self.firebase.update("patients/#{self.uid}/medication_histories/#{self.date.strftime('%F')}/#{self.slot_id}/#{medication_id}", data)
  end

  #----------------------------------------------------------------------------

  def create(slot_id, medication_id, data)
    raise "slot_id is missing" if slot_id.blank?
    raise "medication_id is missing" if medication_id.blank?

    data.reject! {|k,v| k.to_s.include?("$")}
    return self.firebase.set("patients/#{self.uid}/medication_histories/#{self.date.strftime('%F')}/#{slot_id}/#{medication_id}", data)
  end

  #----------------------------------------------------------------------------

  def decide(medication, choice)
    medication_id = medication["$id"] || medication["id"]
    data_hash = medication.merge(:taken_at => nil, :skipped_at => nil).with_indifferent_access
    if choice == "take"
      data_hash["taken_at"] = Time.zone.now
    elsif choice == "skip"
      data_hash["skipped_at"] = Time.zone.now
    end

    # Update the history.
    if self.data.blank?
      resp = self.create(self.slot_id, medication_id, data_hash)
    else
      self.update(medication_id, data_hash)
    end

    # Update the corresponding slot.
    slot = Slot.new(self.uid, self.slot_id)
    slot.get()
    num_meds = slot.data["medications"].length
    self.get()

    if self.data.try(:keys).try(:length).to_i == num_meds
      slot.update({status: "completed"})
    elsif slot.past?
      slot.update({status: "overdue"})
    else
      slot.update({status: "inprogress"})
    end
  end

  #----------------------------------------------------------------------------

  def decide_all(choice)
    schedule = MedicationSchedule.new(self.uid)
    schedule.get()

    medications = schedule.data[self.slot_id] && schedule.data[self.slot_id]["medications"]
    if medications.present?
      med_ids = medications.each do |key, m|
        self.decide(m, choice)
      end
    end
  end

  #----------------------------------------------------------------------------
end
