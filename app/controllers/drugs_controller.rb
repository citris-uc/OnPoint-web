class DrugsController < ActionController::Base
  respond_to :html
  layout "application"

  def show
    respond_with do |format|
      format.html
    end
  end

end
