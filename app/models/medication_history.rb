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

    histories = MedicationHistory.new(uid, Time.zone.now)
    histories.get()

    # At this point,
    if histories.data.blank?
      self.create(uid, Time.zone.now.strftime("%F"), history)
    else
      puts "histories.data; #{histories.data.inspect}"

      matching_history = histories.data.find {|id, data| data["medication_schedule_id"] == schedule_id && data["medication_id"] == medication_id}

      if matching_history.blank?
        self.create(uid, Time.zone.now.strftime("%F"), history)
      else
        self.update(uid, Time.zone.now.strftime("%F"), matching_history[0], history)
      end
    end

  end
end
