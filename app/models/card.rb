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
      if card_data["medication_schedule"].blank? || card_data["medication_schedule"]["medications"].blank?
        slot = Slot.new(uid, card_data["object_id"])
        slot.get()

        card_data["medication_schedule"] = slot.data

        card_data["missed"]    = true
        card_data["completed"] = false
        self.save(card_data)
        return card_data
      end

      # Load the associated medication history and see if the person adheres to it.
      history = MedicationHistory.new(uid, date)
      history.get()
      if history.data.blank?
        card_data["missed"]    = true
        card_data["completed"] = false
        self.save(card_data)
        return card_data
      end

      # At this point, we have all the medications and the medication history
      # to see if the person adheres.
      med_ids_adhered_to = history.data.values.map {|v| v["medication_id"]}
      all_med_ids        = card_data["medication_schedule"]["medications"].values.map {|v| v["id"]}

      if all_med_ids.length == med_ids_adhered_to.length
        card_data["missed"]    = false
        card_data["completed"] = true
      else
        card_data["missed"]    = true
        card_data["completed"] = false
      end

      self.save(card_data)
      return card_data
    end
  end

end
