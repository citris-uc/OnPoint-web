class Card
  def initialize(uid, date, id)
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

  def save(data)
    self.firebase.update("patients/#{self.uid}/cards/#{self.date.strftime("%F")}/#{self.id}", data)
  end

  def destroy
    self.firebase.delete("patients/#{self.uid}/cards/#{self.date.strftime("%F")}/#{self.id}")
  end

  def calculate_completeness(card_data, date)
    if card_data["object_type"] == "appointment"
      card_data["missed"]    = false
      card_data["completed"] = true
      self.save(card_data)
      return card_data
    end


    if card_data["object_type"] == "medication_schedule"
      # Create a slot with medication schedule if it doesn't exist.
      if card_data["medication_schedule"].blank? || card_data["medication_schedule"]["medications"].blank?
        slot = Slot.new(uid, card_data["object_id"])
        slot.get()

        card_data["medication_schedule"] = slot.data

        card_data["missed"]    = true
        card_data["completed"] = false
        self.save(card_data)
        return card_data
      end

      # At this point, we have the medication schedule AND the medications. Extract
      # all the medications.
      all_med_ids = card_data["medication_schedule"]["medications"].values.map {|v| v["id"]}

      # Load the associated medication history and see if the person adheres to it. If
      # we don't have the data, that means the person didn't adhere. Let's set it
      # to number of drugs missed equal to number of medications needed to take.
      history = MedicationHistory.new(uid, date)
      history.get()
      if history.data.blank?
        # TODO: Need to figure out what to do if no medication history exists.
        # card_data["skipped"]   = all_med_ids
        # card_data["taken"]     = []
        # card_data["completed"] = all_med_ids
        # self.save(card_data)
        return card_data
      end

      # Scope the history to the corresponding medication schedule ID.
      scoped_history = history.data.values.find_all {|hist| hist["medication_schedule_id"] == card_data["object_id"]}

      # At this point, we have all the medications and the medication history
      # to see if the person adheres. Let's calculate number of those that were
      # taken and number of those that were skipped.
      med_ids_completed = scoped_history.map {|v| v["medication_id"]}
      med_ids_taken     = scoped_history.find_all {|h| h["taken_at"].present?}.map {|v| v["medication_id"]}
      med_ids_skipped   = scoped_history.find_all {|h| h["skipped_at"].present?}.map {|v| v["medication_id"]}

      card_data["skipped"]   = med_ids_skipped
      card_data["taken"]     = med_ids_taken
      card_data["completed"] = med_ids_completed
      self.save(card_data)
      return card_data
    end
  end

end
