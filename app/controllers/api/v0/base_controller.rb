class API::V0::BaseController < ApplicationController
  def identify_uid
    token = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
    if token.blank?
      raise API::V0::Error.new("Token can't be blank!", 403) and return
    end

    # TODO: Actually use Google's certs to verify this token.
    # See: https://firebase.google.com/docs/auth/admin/verify-id-tokens
    # and https://groups.google.com/forum/#!topic/firebase-talk/iefJWQ9LMQE
    payload = JWT.decode(token, nil, false)
    if payload.blank? || payload[0].blank? || payload[0]["d"].blank?
      raise API::V0::Error.new("Payload is blank!", 403) and return
    end

    uid = payload[0]["d"]["uid"]
    if uid.blank?
      raise API::V0::Error.new("The payload format is incorrect. Is this a valid Firebase token?", 403) and return
    end

    @uid = uid
    return @uid
  end
end
