class Card < ActiveRecord::Base


  # $scope.getMedsStatusArrays = function(schedule, medications, date_key) {
  #   var takeMeds = [];
  #   var skippedMeds = [];
  #   var completedMeds = [];
  #   if (medications != null) {
  #     medications.forEach( function(medication) {
  #       var med = {}
  #       //Find the Med
  #       for(var i = 0; i < $scope.medications.length; i++) {
  #         if ($scope.medications[i].trade_name == medication) {
  #           med = $scope.medications[i]
  #           med.id = $scope.medications[i].$id;
  #         }
  #       }
  #
  #       var exists = false;
  #       //var history_date = $scope.medHistory.$ref().key();
  #
  #       // If the history reference matches the passed in date then check validity
  #       //if (date_key == history_date)
  #       if ($scope.medHistory.hasOwnProperty(date_key)) {
  #         var medHistory = $scope.medHistory[date_key];
  #         // for(var i = 0; i < medHistory.length; i++)
  #         //   var hist = medHistory[i];
  #         for(hist_id in medHistory) {
  #           var hist = medHistory[hist_id];
  #           if (hist.medication_id==med.id && hist.medication_schedule_id==schedule.$id) {
  #             exists = true;
  #             if(hist.taken_at != null)
  #               completedMeds.push(med);
  #             else if (hist.skipped_at != null)
  #               skippedMeds.push(med);
  #             else {
  #               takeMeds.push(med);
  #             }
  #           }
  #         }
  #       }
  #       if (!exists)
  #         takeMeds.push(med);
  #     })
  #   }
  #   return {unfinished: takeMeds, skipped: skippedMeds, done: completedMeds};
  # }

  # /*
  #  * gets the body for each cardClass
  #  * @param index: this is the medication_schedule ID essentailly
  #  * TODO: fix medication_schedule ID to be actually ID in firebase, probbaly need to to do when we push med SCheudle to firebase during onboarding
  #  */
  # //  $scope.description = function(card, date_key) {
  # //    type = card.object_type
  # //    switch(type) {
  # //      case CARD.CATEGORY.MEDICATIONS_SCHEDULE:
  # //        return $scope.getMedicationsDescription(card, date_key);
  # //     //  case CARD.CATEGORY.MEDICATIONS_CABINET :
  # //     //    return $scope.getMedicationsCabinetDescription(card, date_key);
  # //      case CARD.CATEGORY.MEDICATIONS_SCHEDULE_CHANGE:
  # //       return 'Edited Medication Schedule';
  # //      default:
  # //        return [""];
  # //    } // end switch
  # //  }

  # TODO: Convert medications to...
  #   $scope.getMedicationsDescription = function(card, date_key) {
  #    var schedule = $scope.findMedicationScheduleForCard(card);
  #    if (schedule == null) return;
  #    //var date_key = card.shown_at.substring(0,10);
  #
  #    var medications = schedule.medications;
  #    var medStatus = $scope.getMedsStatusArrays(schedule, medications, date_key);
  #    var takeMeds = medStatus.unfinished;
  #    var skippedMeds = medStatus.skipped;
  #    var completedMeds = medStatus.done;
  #
  #    // Create a string for each line for Take/Skipped/Completed meds
  #    // TODO -- is there a clean way to do this in the UI to filter?
  #    //         possible to have different UI templates depending on card category?
  #    string = "";
  #    if (takeMeds.length > 0) {
  #     string += "You need to take ";
  #     string += $scope.constructMedItemString(takeMeds);
  #     string += ". ";
  #   }
  #
  #   if (completedMeds.length > 0) {
  #    string += "So far, you've taken "
  #    string += $scope.constructMedItemString(completedMeds);
  #    if (skippedMeds.length == 0) string += ".";
  #   }
  #
  #    if (skippedMeds.length > 0) {
  #      if (completedMeds.length > 0)
  #       string += " and you've skipped "
  #      else
  #       string += " You've skipped "
  #       string += $scope.constructMedItemString(skippedMeds);
  #       string += ".";
  #    }
  #
  #    if (takeMeds.length == 0 && completedMeds.length == 0 && skippedMeds.length == 0) {
  #      string += "You have no medications scheduled for this time.";
  #    }
  #    return string;
  # }
 #  $scope.constructMedItemString = function(itemsArray) {
 #    var str = "";
 #    for (var i = 0; i < itemsArray.length; i++) {
 #      if (i != 0) str += ", ";
 #      if (i != 0 && i == itemsArray.length - 1) str += " and ";
 #      str += itemsArray[i].trade_name;
 #    }
 #    return str;
 #  }
 #
 # $scope.constructItemString = function(itemsArray) {
 #   var str = "";
 #   for (var i = 0; i < itemsArray.length; i++) {
 #     if (i != 0) str += ", ";
 #     if (i != 0 && i == itemsArray.length - 1) str += " and ";
 #     str += itemsArray[i];
 #   }
 #   return str;
 # }
  def description
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

  # TODO:
  #   $scope.statusClass = function(card, date_key) {
  #   // $scope.checkCardComplete(card, date_key);
  #   // Return cardClass: urgent/active/completed
  #   if(card.type == CARD.TYPE.REMINDER)
  #     return "badge-royal";
  #   if (card.completed_at == null) {
  #     if (card.type == CARD.TYPE.URGENT) {
  #       return "badge-assertive";
  #     } else {
  #       var timeCutoff = new Date();
  #       timeCutoff.setHours(timeCutoff.getHours()+3);
  #       var cardTime = new Date(card.shown_at);
  #       // If shown_at time is within 3 hours of now, mark card as "In Progress"
  #       if (cardTime < timeCutoff) {
  #         return "badge-energized";
  #       } else {
  #         return "badge-calm";
  #       }
  #
  #     }
  #   } else {
  #     return "badge-balanced";
  #   }
  # }
  def status_class
  end


  # TODO:
  # $scope.statusText = function(card, date_key) {
  #   // $scope.checkCardComplete(card, date_key);
  #   // Return cardClass: urgent/active/completed
  #   if (card.type==CARD.TYPE.REMINDER) {
  #     return 'Reminder';
  #   }
  #   if (card.completed_at == null) {
  #     if (card.type == CARD.TYPE.URGENT) {
  #       return "Needs attention";
  #     } else {
  #       var timeCutoff = new Date();
  #       timeCutoff.setHours(timeCutoff.getHours()+3);
  #       var cardTime = new Date(card.shown_at);
  #
  #       // If shown_at time is within 3 hours of now, mark card as "In Progress"
  #       if (cardTime < timeCutoff) {
  #         return "In progress";
  #       } else {
  #         return "Upcoming";
  #       }
  #     }
  #   } else {
  #     return "Completed";
  #   }
  # }
  #
  def status_text
  end

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
