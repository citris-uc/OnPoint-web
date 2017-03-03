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
    return date.strftime("%F")
  end

  def self.appointment_cards_between(uid, start_date, end_date)

    date = start_date
    cards = []
    while (date < end_date.end_of_day)
      cds = self.find_by_uid_and_date(uid, date.strftime("%F"))
      cards += cds.to_a.find_all {|c| c[1]["object_type"] == "appointment"}

      date  += 1.day
    end

    return cards
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

  def self.generate_medication_schedule_cards_for_date(uid, date_string)
    cards = self.find_by_uid_and_date(uid, date_string)

    if cards.nil?
      medication_schedule = MedicationSchedule.find_by_uid(uid)
      return if medication_schedule.blank?

      wday = Time.zone.parse(date_string).wday
      medication_schedule.to_a.each do |s|
        id       = s[0]
        schedule = s[1]

        if schedule["days"][wday] == true
          card             = {}
          card[:action_type] = "action"
          card[:shown_at]    = Time.zone.now
          card[:object_type] = "medication_schedule"
          card[:object_id]   = id
          card[:medication_schedule] = schedule
          Card.sava(uid, date_string, card)
        end
      end
    else
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

  def self.generate_appointment_card(uid, id, appt_params)
    date        = appt_params[:date]
    date_string = Card.format_date(Time.parse(date))

    card               = {}
    card[:action_type] = "action"
    card[:object_type] = "appointment"
    card[:object_id]   = id
    card[:appointment] = appt_params
    Card.sava(uid, date_string, card)
  end

  def self.destroy_appointment_card(uid, firebase_id, date_string)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])

    cards = self.find_by_uid_and_date(uid, date_string)
    return nil if cards.blank?

    matching_card = cards.to_a.find {|c| c[1]["object_id"] == firebase_id}
    if matching_card.present?
      firebase.delete("patients/#{uid}/cards/#{date_string}/#{matching_card[0]}")
    end
  end
end
