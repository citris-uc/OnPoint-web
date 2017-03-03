class API::V0::CardsController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # GET /api/v0/cards
  def index
    if params[:upcoming].present?
      @cards = []

      # Find all cards. Create medication schedule cards.
      cards = Card.find_by_uid_and_date(@uid, Time.zone.now.strftime("%F"))
      if cards.blank?
        today = Card.format_date(Time.zone.today)
        Card.generate_medication_schedule_cards_for_date(@uid, today)
        cards = Card.find_by_uid_and_date(@uid, Time.zone.now.strftime("%F"))
      end

      # Add the medication schedule only if it's not in the past.
      cards.to_a.each do |c|
        if c[1]["object_type"] == "medication_schedule"
          t = Time.zone.parse(c[1]["medication_schedule"]["time"])
          if (Time.zone.now < t + 2.hours)
            @cards << c
          end
        end
      end

      # Find appointment cards.
      start_date = Time.zone.now
      end_date   = start_date + 1.week
      @cards    += Card.appointment_cards_between(@uid, start_date, end_date)
    end
  end

  #----------------------------------------------------------------------------
  # DELETE /api/v0/cards/force
  # This method will force-generate cards for today and tomorrow.
  # This OVERWRITES any existing schedule. Why? Because it's currently only
  # called from when creating/editing medication schedule.
  def force
    Card.destroy_all_from(@uid, Time.zone.today)

    today = Card.format_date(Time.zone.today)
    tomm  = Card.format_date(Time.zone.tomorrow)
    Card.generate_cards_for_date(@uid, today)
    Card.generate_cards_for_date(@uid, tomm)
  end


  #----------------------------------------------------------------------------
  # PUT /api/v0/cards/appointment
  # This method will force-generate cards for today and tomorrow.
  # This OVERWRITES any existing schedule. Why? Because it's currently only
  # called from when creating/editing medication schedule.
  def appointment
    puts "params; #{params[:appointment]}"
    Card.generate_appointment_card(@uid, params[:firebase_id], params[:appointment])
  end

  #----------------------------------------------------------------------------
  # DELETE /api/v0/cards/destroy_appointment
  # This method will force-generate cards for today and tomorrow.
  # This OVERWRITES any existing schedule. Why? Because it's currently only
  # called from when creating/editing medication schedule.
  def destroy_appointment
    puts "@uid: #{@uid}"
    if params[:firebase_id].blank?
      puts "FIREBASE IS BLANK"
      raise API::V0::Error.new("Firebase ID can't be blank", 403) and return
    end

    if params[:appointment_date].blank?
      puts "APPIINTMENT DATE IS BLANK"
      raise API::V0::Error.new("Appointment date can't be blank", 403) and return
    end

    puts "DELETEING CARD!"

    Card.destroy_appointment_card(@uid, params[:firebase_id], params[:appointment_date])
  end

end
