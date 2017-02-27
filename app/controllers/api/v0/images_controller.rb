class API::V0::ImagesController < API::V0::BaseController
  #----------------------------------------------------------------------------
  # PUT /api/v0/ocrs/parse_from_mobile

  def parse_from_mobile
    @image = Image.new("")

    begin
      puts "PARSING!"
      @image.convert_to_text_from_base64(params[:base64_photo])
      puts "FINISHED PARSING!\n\n\n"

    rescue StandardError => e
      puts "\n\n\n\nRescuing error = #{e.message}\n\n\n"
      render :json => {:error => e.message}, :status => 422 and return
    end

    @image.parse()
    render "api/v0/images/parse" and return
  end


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

    puts "\n\n\n\nConverting to text...\n\n\n"
    begin
      @image.convert_to_text()
    rescue StandardError => e
      puts "\n\n\n\nRescuing error = #{e.inspect}\n\n\n"
      render :json => {:error => e}, :status => 422 and return
    end

    @image.parse()
  end
end
