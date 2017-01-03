class API::V0::CardsController < API::V0::BaseController

  def index
    token = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
    if token.blank?
      raise API::V0::Error.new("Token can't be blank!") and return
    end

    # TODO: Actually use Google's certs to verify this token.
    # See: https://firebase.google.com/docs/auth/admin/verify-id-tokens
    # and https://groups.google.com/forum/#!topic/firebase-talk/iefJWQ9LMQE
    payload = JWT.decode(token, nil, false)
    if payload.blank? || payload[0].blank? || payload[0]["d"].blank?
      raise API::V0::Error.new("Payload is blank!") and return
    end

    uid = payload[0]["d"]["uid"]
    if uid.blank?
      raise API::V0::Error.new("The payload format is incorrect. Is this a valid Firebase token?") and return
    end

    # At this point, we have the UID. Let's query the cards.
    if params[:when] == "today"
      @cards = Card.find_by_uid_and_date(uid, Time.zone.now.strftime("%Y-%m-%d"))
    end

    @uid = uid
    # Card.find_schedule_by_uid_and_card(uid, "test")
    # Card.generate_cards_for_date(uid, Time.zone.now.strftime("%Y-%m-%d"))
  end

end
