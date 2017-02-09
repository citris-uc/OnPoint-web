class API::V0::ImagesController < API::V0::BaseController
  #----------------------------------------------------------------------------
  # GET /api/v0/ocrs/parse

  def parse
    image     = params[:image][:id]
    file_path = Rails.root.join("app", "assets", "images", "test", image)

    resource   = OcrSpace::Resource.new(apikey: "0ad729224588957")
    result_str = resource.clean_convert file: file_path
    @parsed_response = result_str.split.join(" ").upcase


    $drug_list = []
    processed_drugs_file = Rails.root.join("lib", "drugs_processed.txt")
    File.open(processed_drugs_file, "r") do |f|
      f.each_line do |line|
        $drug_list.push(line.upcase.squeeze(" ").strip)
      end
    end

    @parsed_result             = {}
    @parsed_result[:name]      = get_drug_name(@parsed_response)
    @parsed_result[:delivery]  = get_delivery_method(@parsed_response)
    @parsed_result[:amount]    = get_amount_to_take(@parsed_response)
    @parsed_result[:frequency] = get_freq_to_take(@parsed_response)
  end


  # $drug_list = []
  # File.open("/home/nduncan/Documents/ocr_pills/drugs_processed.txt", "r") do |f|
  #   f.each_line do |line|
  #     $drug_list.push(line.upcase.squeeze(" ").strip)
  #   end
  # end
  #
  def find_drug_name_match(str1)
    for drug_name in $drug_list
      if drug_name == str1
        return drug_name
      end
    end

    return nil
  end

  def get_drug_name(str1)
    str_split = str1.split()

    for word in str_split
      result = find_drug_name_match(word)
      if result
        return result
      end
    end

    return nil
  end

  def get_str_from_regex(str1, r1)
    match = r1.match(str1)

    if not match
      return nil
    else
      return match[0]
    end
  end

  def get_amount_to_take(str1)
    get_str_from_regex(str1, /(((\d)-(\d))|((\d)+)) (TABLET|CAPSULE)(S){0,1}/)
  end

  def get_freq_to_take(str1)
    get_str_from_regex(str1, /(EVERY (((\d)+ (\w)+)|((\w)+)))|((\w)+ DAILY)|(AT (\w)+)/)
  end

  def get_delivery_method(str1)
    get_str_from_regex(str1, /(BY MOUTH)|(BY DICK)|(SWALLOW (\w)+)/)
  end


end
