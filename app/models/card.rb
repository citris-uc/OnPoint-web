class Card
  def initialize(uid, date_string, card_id)
    @uid = uid
    @id  = card_id
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "id")

    # Example response:
    # {
    #   "action_type"=>"action",
    #   "object_id"=>"-K_1l5MScJdm1tLxwpWr",
    #   "object_type"=>"medication_schedule",
    #   "shown_at"=>"2017-01-05T23:07:57.325Z"
    # }
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    card_hash = firebase.get("patients/#{uid}/cards/#{date_string}/#{card_id}").body
    if card_hash.blank?
      raise "Couldn't find card in Firebase!"
      return
    end

    card_hash.each do |name, value|
      instance_variable_set("@" + name, value)
      self.class.send(:attr_accessor, name)
    end
  end

  #----------------------------------------------------------------------------

  def self.format_date(date)
    return date.strftime("%Y-%m-%d")
  end


  #   $scope.getMedicationsDescription = function(card, date_key) {
  def self.description(uid, card)
    # TODO: Is the date key supposd to be toda?
    date_key = Time.zone.now.strftime("%Y-%m-%d")

    schedule = MedicationSchedule.find_by_card(uid, card)
    return nil if schedule.blank?

    # At this point, we have a schedule.
    medications    = schedule["medications"]
    med_status     = Medication.segment_by_state(uid, card["object_id"], medications, date_key)

    take_meds      = med_status[:unfinished]
    skipped_meds   = med_status[:skipped]
    completed_meds = med_status[:done]



    string = ""
    if take_meds.length > 0
      string += "You need to take "
      string += self.construct_med_item_string(take_meds)
      string += ". "
    end

    if completed_meds.length > 0
      string += "So far, you've taken "
      string += self.construct_med_item_string(completed_meds)
      if skipped_meds.length == 0
        string += "."
      end
    end

    if skipped_meds.length > 0
      if completed_meds.length > 0
        string += " and you've skipped "
        string += self.construct_med_item_string(skipped_meds)
        string += "."

      else
        string += " You've skipped "
        string += self.construct_med_item_string(skipped_meds)
        string += "."
      end
    end

    if take_meds.length == 0 && completed_meds.length == 0 && skipped_meds.length == 0
      string += "You have no medications scheduled for this time."
    end

    return string
  end

  #  $scope.constructMedItemString = function(itemsArray) {
  def self.construct_med_item_string(medications)
    str = ""
    medications.each_with_index do |item, index|
      str += ", " if index != 0
      # raise "item: #{item.inspect}\n\n\n item.values = #{item[:data]}"
      str += item["trade_name"]
    end

    return str
  end

  # TODO:
  # $scope.completeFinishedMedications = function(card, date_key) {
  #   if (card.completed_at != null || card.archived_at != null) return;
  #
  #   var schedule = $scope.findMedicationScheduleForCard(card)
  #   if (schedule == null) return;
  #
  #   var medications = schedule.medications;
  #   if (medications == null) return;
  #
  #   var now = (new Date()).toISOString();
  #   var medStatus     = $scope.getMedsStatusArrays(schedule, medications, date_key);
  #   var takeMeds      = medStatus.unfinished;
  #   var skippedMeds   = medStatus.skipped;
  #   var completedMeds = medStatus.done;
  #
  #   if (takeMeds.length == 0 && skippedMeds.length==0) {
  #     Card.complete(card);
  #   }
  # }
  def complete_card
  end

  def self.status_class(card)
    if card["type"] == "reminder"
      return "badge-royal"
    end

    if card["completed_at"].blank?
      if card["type"] == "urgent"
        return "badge-assertive"
      else
        now = Time.zone.now
        shown_at = Time.zone.parse(card["shown_at"])
        return "badge-energized" if (now - shown_at).abs <= 3.hours
        return "badge-calm"
      end
    else
      return "badge-balanced"
    end
  end

  def self.status_text(card)
    if card["type"] == "reminder"
      return "Reminder"
    end

    if card["completed_at"].blank?
      if card["type"] == "urgent"
        return "Needs attention"
      else
        now = Time.zone.now
        shown_at = Time.zone.parse(card["shown_at"])
        return "In Progress" if (now - shown_at).abs <= 3.hours
        return "Upcoming"
      end
    else
      return "Completed"
    end
  end

  # TODO
  def scheduled_at
    # {
    #   "archived_at":"2016-12-30T21:48:10.957Z",
    #   "completed_at":"2016-12-30T21:43:33.524Z",
    #   "created_at":"2016-12-30T01:15:39.300Z",
    #   "num_comments":0,
    #   "object_id":"-K_1l5MScJdm1tLxwpWr",
    #   "object_type":"medications_schedule",
    #   "shown_at":"2016-12-29T16:00:38.831Z",
    #   "type":"action",
    #   "updated_at":"2016-12-30T21:48:10.957Z"
    # }
  end

  def self.title(card)
    return "Medication Reminder"
  end

  def self.formatted_timestamp(card)

  end

  # uid = 1dae2ad5-9d3c-407c-9d8e-6f3796f0a2ec
  def self.sava(uid, date_string, data)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    path = "patients/#{uid}/cards/#{date_string}"
    puts "data: #{data}"
    response = firebase.push(path, data)
    puts "response: #{response.inspect}"
  end

  def self.update(uid, id, date, data)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    path = "patients/#{uid}/cards/#{date}/#{id}"
    puts "data: #{data}"
    response = firebase.update(path, data)
    puts "response: #{response.inspect}"

  end


  def self.destroy_all_from(uid, date)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])

    date = date.beginning_of_day
    [date, date + 1.day, date + 2.days, date + 3.days].each do |d|
      date_string = Card.format_date(d)
      firebase.delete("patients/#{uid}/cards/#{date_string}")
    end
  end

  def self.generate_cards_for_date(uid, date_string)
    cards = self.find_by_uid_and_date(uid, date_string)
    if cards.nil?
      # that.createFromObjectForDate(CARD.CATEGORY.MEDICATIONS_SCHEDULE, date)
      # date = date
      # 'medications_schedule'
      # var defaultRef = MedicationSchedule.ref();
      #     this.createFromSchedule(defaultRef, object_type, date);
      medication_schedule = MedicationSchedule.find_by_uid(uid)
      return if medication_schedule.blank?
      # this.createFromSchedule(medication_schedule, 'medication_schedule', date);

      wday = Time.zone.parse(date_string).wday
      # ["-K_1l5MScJdm1tLxwpWr", {"days"=>[true, true, true, true, true, true, true], "medications"=>["Lasix", "Toprol XL", "Zestril", "Coumadin", "Riomet"], "slot"=>"Morning", "time"=>"08:00"}]
      medication_schedule.each do |id, schedule|
        puts "id: #{id}"
        puts "schedule: #{schedule}"
        if schedule["days"][wday] == true
          # card = Card.new
          card             = {}
          card[:action_type] = "action"
          card[:shown_at]    = Time.zone.now
          card[:object_type] = "medication_schedule"
          card[:object_id]   = id


          # TODO: card push date, card
          Card.sava(uid, date_string, card)
        end
      end


    else
      # // Check to make sure each has been generated
      #       // var measExists = false;
      #       var medsExists = false;
      #       // var apptExists = false;
      #       cardSnap.forEach(function(childSnap) {
      #         // if (childSnap.val().object_type == CARD.CATEGORY.MEASUREMENTS_SCHEDULE) measExists = true;
      #         if (childSnap.val().object_type == CARD.CATEGORY.MEDICATIONS_SCHEDULE) medsExists = true;
      #         // if (childSnap.val().object_type == CARD.CATEGORY.APPOINTMENTS) apptExists = true;
      #       });
      #       if (!medsExists)
      #         that.createFromObjectForDate(CARD.CATEGORY.MEDICATIONS_SCHEDULE, date)
      #
      #       // if (!measExists)
      #       //   that.createFromObjectForDate(CARD.CATEGORY.MEASUREMENTS_SCHEDULE, date)
      #       // if (!apptExists)
      #       //   that.createFromObjectForDate(CARD.CATEGORY.APPOINTMENTS, date);
      return cards
    end


  end

  def self.find_by_uid_and_date(uid, date_string)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/cards/#{date_string}").body
  end

  # TODO: Calculate past.
  def self.find_past_by_uid(uid)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/cards/#{Time.zone.yesterday.strftime('%Y-%m-%d')}").body
  end

  # def self.update_shown_at(uid, date_string, card_id)
  #   card = self.find_by_date_and_id(uid, date_string, card_id)
  #   if card.present?
  #
  #   end
  #
  #   if cards.present?
  #     cards.each do |id, card|
  #       puts "card: #{card.inspect}"
  #       if card["object_id"] == object_id && card["object_type"] == object_type
  #
  #         # If the new object is meant to be asked today, then let's go ahead and update it.
  #         wday = Time.zone.parse(date_string)
  #         if slot["days"][wday] == true
  #           time = Time.parse(slot["time"])
  #           date = Time.zone.parse(date_string)
  #           date.hours = time.hours
  #           date.minutes = time.minutes
  #
  #           self.update(uid, id, date_string, {:shown_at => date.iso8601})
  #         end
  #       end
  #     end
  #   end
  # end

end
