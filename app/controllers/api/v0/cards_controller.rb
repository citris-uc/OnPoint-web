class API::V0::CardsController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # GET /api/v0/cards
  def index
    # At this point, we have the UID. Let's query the cards.
    if params[:when] == "today"
      @cards = Card.find_by_uid_and_date(@uid, Time.zone.now.strftime("%Y-%m-%d"))

      if @cards.blank?
        today = Card.format_date(Time.zone.today)
        Card.generate_cards_for_date(@uid, today)
        @cards = Card.find_by_uid_and_date(@uid, Time.zone.now.strftime("%Y-%m-%d"))
      end


    elsif params[:when] == "past"
      @cards = Card.find_past_by_uid(@uid)
    end
    # Card.find_schedule_by_uid_and_card(uid, "test")
    # Card.generate_cards_for_date(uid, Time.zone.now.strftime("%Y-%m-%d"))
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
