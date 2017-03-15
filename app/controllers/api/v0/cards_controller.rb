class API::V0::CardsController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # GET /api/v0/cards
  def index
    if params[:upcoming].present?
      @cards = []

      today = Time.zone.today.strftime("%F")

      # Find all cards. Create medication schedule cards.
      cards = Cards.new(@uid, Time.zone.today)
      cards.get()
      cards.generate_from_medication_schedule_if_none()

      # Add the medication schedule only if it's not in the past.
      cards.data.to_a.each do |c|
        @cards << c
      end

      # Find appointment cards.
      start_date = Time.zone.now
      end_date   = start_date + 1.week
      @cards    += cards.appointment_cards_between(start_date, end_date)
    end
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/cards/history
  def history
    end_date = Time.zone.parse(params[:end_date])

    @cards = {}
    (1..3).to_a.each do |d|
      @end_date_string = (end_date - d.days).strftime("%F")
      cards = Cards.new(@uid, end_date - d.days)
      cards.get()
      @cards[@end_date_string] = cards || {}
    end
  end


  #----------------------------------------------------------------------------
  # DELETE /api/v0/cards/force
  # This method will force-generate cards for today and tomorrow.
  # This OVERWRITES any existing schedule. Why? Because it's currently only
  # called from when creating/editing medication schedule.
  def force
    cards.destroy()

    cards = Cards.new(@uid, Time.zone.today)
    cards.generate_from_medication_schedule()

    cards = Cards.new(@uid, Time.zone.tomorrow)
    cards.generate_from_medication_schedule()
  end


  #----------------------------------------------------------------------------
  # PUT /api/v0/cards/appointment
  # This method will force-generate cards for today and tomorrow.
  # This OVERWRITES any existing schedule. Why? Because it's currently only
  # called from when creating/editing medication schedule.
  def appointment
    begin
      date = Time.zone.parse(params[:appointment][:date])
    rescue
      raise API::V0::Error.new("We couldn't parse the appointment date. Please try again!", 403) and return
    end

    # Construct the card hash.
    card_hash               = {}
    card_hash[:action_type] = "action"
    card_hash[:object_type] = "appointment"
    card_hash[:object_id]   = params[:firebase_id]
    card_hash[:appointment]      = params[:appointment]

    cards = Cards.new(@uid, date)
    cards.add(card_hash)
    render :json => {}, :status => :ok and return
  end

  #----------------------------------------------------------------------------
  # DELETE /api/v0/cards/destroy_appointment

  def destroy_appointment
    date = Time.zone.parse(params[:appointment_date])
    card = Card.new(@uid, date, params[:firebase_id])
    card.destroy()
    render :json => {}, :status => :ok and return
  end

end
