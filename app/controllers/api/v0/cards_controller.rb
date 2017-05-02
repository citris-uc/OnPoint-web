class API::V0::CardsController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # GET /api/v0/cards

  def index
    @patient = Patient.new(@uid)

    @dates = {}
    [Time.zone.today, Time.zone.tomorrow].to_a.each do |date|
      @patient.generate_cards_for_date(date)
      cards = Card.new(@uid, date)
      cards.get()
      @dates[date.strftime("%F")] = cards || {}
    end
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/cards/history
  def history
    end_date = Time.zone.parse(params[:end_date])

    @dates = {}
    (1..3).to_a.each do |d|
      @end_date_string = (end_date - d.days).strftime("%F")
      cards = Card.new(@uid, end_date - d.days)
      cards.get()
      @dates[@end_date_string] = cards || {}
    end
  end

  #----------------------------------------------------------------------------
  # DELETE /api/v0/cards/force
  # This method will force-generate cards for today and tomorrow.
  # This OVERWRITES any existing schedule. Why? Because it's currently only
  # called from when creating/editing medication schedule.
  def force
    cards = Card.new(@uid, Time.zone.today)
    cards.destroy_all
    cards = Card.new(@uid, Time.zone.tomorrow)
    cards.destroy_all
  end


  #----------------------------------------------------------------------------
  # PUT /api/v0/cards/appointment

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
    card_hash[:appointment] = params[:appointment]

    cards = Cards.new(@uid, date)
    cards.add(card_hash)
    render :json => {}, :status => :ok and return
  end

  #----------------------------------------------------------------------------
  # DELETE /api/v0/cards/destroy_appointment

  def destroy_appointment
    date = Time.zone.parse(params[:appointment_date])

    card = Card.new(@uid, date, params[:appointment_id])
    card.get()
    c.destroy if card.data.present?
    render :json => {}, :status => :ok and return
  end

end
