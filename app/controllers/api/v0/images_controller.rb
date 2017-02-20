class API::V0::ImagesController < API::V0::BaseController
  #----------------------------------------------------------------------------
  # PUT /api/v0/ocrs/parse

  def parse
    if params[:image] && params[:image][:id]
      image     = params[:image][:id]
      file_path = Rails.root.join("app", "assets", "images", "test", image)
    else
      file_path = params[:file].path
    end

    # TODO: OCR space gem doesn't properly handle errors.
    # resource   = OcrSpace::Resource.new(apikey: "0ad729224588957")
    # result_str = resource.clean_convert file: file_path

    @image = Image.new(file_path)

    begin
      @image.convert_to_text()
    rescue StandardError => e
      render :json => {:error => e}, :status => 422 and return
    end

    @image.parse()
  end
end
