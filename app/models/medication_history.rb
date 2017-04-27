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
      data_hash["taken_at"] = self.date
    elsif choice == "skip"
      data_hash["skipped_at"] = self.date
    end

    # Update the history.
    if self.data.blank?
      resp = self.create(self.slot_id, medication_id, data_hash)
    else
      self.update(medication_id, data_hash)
    end

    # Load the data.
    self.get()

    # Update the corresponding slot.
    slot = Slot.new(self.uid, self.slot_id)
    slot.get()
    return nil if slot.data.blank?

    # Fetch the card associated with this medication schedule.
    card = Card.new(self.uid, self.date, self.slot_id)
    card.get()

    # Update the status.
    if self.data.try(:keys).try(:length).to_i == slot.data["medications"].length
      card.update({status: "completed"})
    elsif slot.past?
      card.update({status: "overdue"})
    else
      card.update({status: "inprogress"})
    end

    # Update skipped, completed, etc.
    card.data["taken_medications"]   ||= []
    card.data["skipped_medications"] ||= []

    med_name = medication["nickname"] || medication["name"]
    if choice == "take"
      card.data["skipped_medications"].delete(med_name)
      card.data["taken_medications"] << med_name unless card.data["taken_medications"].include?(med_name)
    elsif choice == "skip"
      card.data["taken_medications"].delete(med_name)
      card.data["skipped_medications"] << med_name unless card.data["skipped_medications"].include?(med_name)
    end

    card.update(card.data)
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
