class Card
  def initialize(uid, date, id = nil)
    @uid  = uid
    @date = date
    @id  = id
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "date")
    self.class.send(:attr_accessor, "id")
    self.class.send(:attr_accessor, "data")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")

    return self
  end

  #----------------------------------------------------------------------------

  def self.get_all
    return self.firebase.get("patients/#{self.uid}/cards/#{self.date.strftime("%F")}").body
  end
  #
  def create(data)
    raise "Card#id is not present" if self.id.blank?
    return self.firebase.set("patients/#{self.uid}/cards/#{self.date.strftime("%F")}/#{self.id}", data)
  end


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
    self.data = self.firebase.get("patients/#{self.uid}/cards/#{self.date.strftime("%F")}/#{self.id}").body
    return self.data
  end

  def update(data)
    self.firebase.update("patients/#{self.uid}/cards/#{self.date.strftime("%F")}/#{self.id}", data)
  end

  def destroy
    self.firebase.delete("patients/#{self.uid}/cards/#{self.date.strftime("%F")}/#{self.id}")
  end

  def destroy_all
    self.firebase.delete("patients/#{self.uid}/cards/#{self.date.strftime("%F")}")
  end

  def calculate_status
    self.get()
    if self.data["object_type"] == "appointment"
      self.data["missed"]    = false
      self.data["completed"] = true
      self.update(self.data)
      return self.data
    end

    if self.data["object_type"] == "medication_schedule"
      # Create a slot with medication schedule if it doesn't exist.
      if self.data["medication_schedule"].blank? || self.data["medication_schedule"]["medications"].blank?
        slot = Slot.new(uid, self.data["object_id"])
        slot.get()

        self.data["medication_schedule"] = slot.data
        self.update(self.data)
      end

      # At this point, we have the medication schedule AND the medications. Extract
      # all the medications.
      slot = Slot.new(uid, self.data["object_id"])
      slot.get()
      med_ids = slot.data["medications"].keys

      # Load the associated medication history and see if the person adheres to it. If
      # we don't have the data, that means the person didn't adhere. Let's set it
      # to number of drugs missed equal to number of medications needed to take.
      history = MedicationHistory.new(uid, self.date, self.data["object_id"])
      history.get()
      if history.data.blank?
        # TODO: Need to figure out what to do if no medication history exists.
        return self.data
      end

      # At this point, we have all the medications and the medication history
      # to see if the person adheres. Let's calculate number of those that were
      # taken and number of those that were skipped.
      med_ids_completed = []
      med_ids_taken     = []
      med_ids_skipped   = []
      med_ids.each do |med_id|
        med_ids_completed << med_id

        if history.data[med_id]["taken_at"].present?
          med_ids_taken << med_id
        elsif history.data[med_id]["skipped_at"].present?
          med_ids_skipped << med_id
        end
      end

      # Finally, calculate status
      if history.data.try(:keys).try(:length).to_i == med_ids.length
        self.update({status: "completed"})
      elsif slot.past?
        self.update({status: "overdue"})
      else
        self.update({status: "inprogress"})
      end

      self.data["skipped"]   = med_ids_skipped
      self.data["taken"]     = med_ids_taken
      self.data["completed"] = med_ids_completed
      self.update(self.data)
      return self.data
    end
  end


end
