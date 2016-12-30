class Card < ActiveRecord::Base
  # uid = 1dae2ad5-9d3c-407c-9d8e-6f3796f0a2ec

  def self.sava(uid, date, data)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    path = "patients/#{uid}/cards/#{date}"
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

  def self.generate_cards_for_date(uid, date)
    beginning_of_day = Time.zone.now.beginning_of_day
    end_of_day       = Time.zone.now.end_of_day

    cards = self.find_by_uid_and_date(uid, date)
    if cards.nil?
      # that.createFromObjectForDate(CARD.CATEGORY.MEDICATIONS_SCHEDULE, date)
      # date = date
      # 'medications_schedule'
      # var defaultRef = MedicationSchedule.ref();
      #     this.createFromSchedule(defaultRef, object_type, date);
      medication_schedule = MedicationSchedule.find_by_uid(uid)
      # this.createFromSchedule(medication_schedule, 'medication_schedule', date);

      time = Time.zone.parse(date)
      wday = time.wday
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
          Card.sava(uid, date, card)
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
    puts "patients/#{uid}cards/#{date_string}"
    return firebase.get("patients/#{uid}/cards/#{date_string}").body
  end

  def self.update_card_for_date(uid, date_string, object_id, object_type, slot)
    cards = self.find_by_uid_and_date(uid, date_string)
    if cards.present?
      cards.each do |id, card|
        puts "card: #{card.inspect}"
        if card["object_id"] == object_id && card["object_type"] == object_type

          # If the new object is meant to be asked today, then let's go ahead and update it.
          wday = Time.zone.parse(date_string)
          if slot["days"][wday] == true
            time = Time.parse(slot["time"])
            date = Time.zone.parse(date_string)
            date.hours = time.hours
            date.minutes = time.minutes

            self.update(uid, id, date_string, {:shown_at => date.iso8601})
          end
        end
      end
    end
  end
end
