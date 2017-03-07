class MedicationHistory
  def initialize(uid, date)
    @uid  = uid
    @date = date
    self.class.send(:attr_accessor, "uid")
    self.class.send(:attr_accessor, "date")
    self.class.send(:attr_accessor, "data")

    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    self.class.send(:attr_accessor, "firebase")
    return self
  end

  def get
    self.data = self.firebase.get("patients/#{self.uid}/medication_histories/#{self.date.strftime('%F')}").body
    return self.data
  end

  # uid = 1dae2ad5-9d3c-407c-9d8e-6f3796f0a2ec
  def self.find_by_uid(uid)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/medication_histories").body
  end

  def self.create(uid, date_string, data)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    response = firebase.push("patients/#{uid}/medication_histories/#{date_string}", data)
  end

  def self.update(uid, date_string, medication_history_id, data)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    puts "medication_history_id, = #{medication_history_id}\n\n\n"
    response = firebase.update("patients/#{uid}/medication_histories/#{date_string}/#{medication_history_id}", data)
  end

  def self.find_all_by_date_and_schedule_id(uid, date_string, schedule_id)
    history = self.better_find_by_date(uid, date_string)
    return nil if history.blank?
    return history.find_all {|id, data| data["medication_schedule_id"] == schedule_id}
  end

  def self.find_by_date_and_schedule_id_and_medication_id(uid, date_string, schedule_id, medication_id)
    history = self.better_find_by_date(uid, date_string)
    return nil if history.blank?
    match = history.find {|id, data| data["medication_schedule_id"] == schedule_id && data["medication_id"] == medication_id}
    return nil if match.blank?
    return {
      :id => match[0],
      :data => match[1]
    }
  end

  def self.better_find_by_date(uid, date_string)
    firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])
    return firebase.get("patients/#{uid}/medication_histories/#{date_string}").body
  end

  def self.create_or_update(uid, medication_id, schedule_id, choice)

    history = {medication_id: medication_id, medication_schedule_id: schedule_id, :taken_at => nil, :skipped_at => nil}
    if choice == "take"
      history["taken_at"] = Time.zone.now
    elsif choice == "skip"
      history["skipped_at"] = Time.zone.now
    end

    if schedule_id == "cabinet"
      # "TODO"
      #       instanceFB.reason = typeof(medication.reason)==='undefined'? null:medication.reason;
      #       var medRef = snapshot.ref();
      #       cabHistRef = medRef.push(instanceFB);
      #       // TODO :This no longer exists because we use "force" in Rails.
      #       Card.createAdHoc(CARD.CATEGORY.MEDICATIONS_CABINET, cabHistRef.key(), (new Date()).toISOString())

    else
      date_string = Time.zone.now.strftime("%F") #Card.format_date(Time.zone.now)
      existing_history_for_date     = self.better_find_by_date(uid, date_string)

      # At this point,
      if existing_history_for_date.blank?
        self.create(uid, date_string, history)
      else
        # If this exists, let's go ahead and make sure we're not updating one.
        match = self.find_by_date_and_schedule_id_and_medication_id(uid, date_string, schedule_id, medication_id)
        if match.blank?
          self.create(uid, date_string, history)
        else
          self.update(uid, date_string, match[:id], history)
        end

      end

    end
  end
end
