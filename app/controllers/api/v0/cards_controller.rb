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
      date  = (end_date - d.days)
      cards = Card.new(@uid, date)
      cards.get()
      @dates[date.strftime("%F")] = cards || {}

      # The last date.
      @end_date_string = date
    end
  end

  #----------------------------------------------------------------------------
  # DELETE /api/v0/cards/upcoming
  # NOTE: Deleting everything is simpler than trying to stitch
  # changes in the medication schedule. Besides, when CardsController#index
  # is called, we automatically create the cards if they don't exist.

  def destroy_upcoming
    cards = Card.new(@uid, Time.zone.today)
    cards.destroy_all
    cards = Card.new(@uid, Time.zone.tomorrow)
    cards.destroy_all
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
