class API::V0::CardsController < API::V0::BaseController
  before_action :identify_uid

  #----------------------------------------------------------------------------
  # GET /api/v0/cards
  def index
    if params[:upcoming].present?
      @dates = {}
      [Time.zone.today, Time.zone.tomorrow].to_a.each do |d|
        @end_date_string = d.strftime("%F")

        cards = Cards.new(@uid, d)
        cards.get()

        cards.generate_from_medication_schedule_if_none()
        cards.get()
        @dates[@end_date_string] = cards || {}
      end
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
    cards = Cards.new(@uid, Time.zone.today)
    cards.destroy()
    cards = Cards.new(@uid, Time.zone.tomorrow)
    cards.destroy()

    cards = Cards.new(@uid, Time.zone.today)
    cards.generate_from_medication_schedule()

    cards = Cards.new(@uid, Time.zone.tomorrow)
    cards.generate_from_medication_schedule()
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
    cards = Cards.new(@uid, date)
    cards.get()
    matching_appt_card = cards.data.find {|cid, cdata| cdata["object_id"] == params[:firebase_id]}
    if matching_appt_card.present?
      card = Card.new(@uid, date, matching_appt_card[0])
      card.destroy()
    end
    render :json => {}, :status => :ok and return
  end

end
