class ImagesController < ActionController::Base
  respond_to :html
  layout "application"

  def index
    @images = []
    (4..12).to_a.each_with_index do |el, index|
      @images << {:id => "test#{el}.jpg", :path => ActionController::Base.helpers.asset_path("test/test#{el}.jpg")}
    end
    # image_paths = (4..12).to_a.map {|i| ActionController::Base.helpers.asset_path("test/test#{i}.jpg")}



    respond_with do |format|
      format.html
    end
  end

end
