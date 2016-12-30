class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  #-------------------------------------------------------------------------------------------------

  # This allows us to cleanly handle all possible API errors. If something happens, we simply
  # raise this error and it takes care of rendering the correct JSON response.
  class API::V0::Error < StandardError
    attr :message
    attr :status_code

    def initialize(error_msg, error_status_code)
      @message     = error_msg
      @status_code = error_status_code
    end
  end

  #-------------------------------------------------------------------------------------------------
  rescue_from API::V0::Error, :with => :render_json_with_exception

  # This handles access control for all subclasses -- just need to raise the exception (above) and initialize it.
  def render_json_with_exception(exception)
    render :json => { :error => exception.message }, :status => exception.status_code
  end

end
