def levenshtein_distance(s, t)
  m = s.length
  n = t.length
  return m if n == 0
  return n if m == 0
  d = Array.new(m+1) {Array.new(n+1)}

  (0..m).each {|i| d[i][0] = i}
  (0..n).each {|j| d[0][j] = j}
  (1..n).each do |j|
    (1..m).each do |i|
      d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
                  d[i-1][j-1]       # no operation required
                else
                  [ d[i-1][j]+1,    # deletion
                    d[i][j-1]+1,    # insertion
                    d[i-1][j-1]+1,  # substitution
                  ].min
                end
    end
  end
  d[m][n]
end

class Image

  @@units = [
      {value: "mg", display: "mg", for_match: "mg"},
      {value: "ml", display: "ml", for_match: "ml"},
      {value: "micrograms", display: "micrograms", for_match: "microgram"},
      {value: "tablets", display: "tablets", for_match: "tablet"},
      {value: "capsules", display: "capsules", for_match: "capsule"},
      {value: "spray", display: "spray", for_match: "spray"},
      {value: "inhalation", display: "inhalation", for_match: "inhalation"}
    ]

  @@units_normalized = @@units.map{|x| x[:for_match].upcase}

  @@administrations = [
      "Oral",
      "Topical",
      "Sublingual",
      "Intravenous",
      "Intramuscular",
      "Inhalation",
      "Rectal",
      "Vaginal",
      "Intraperitoneal"
    ]

  @@frequencies = [
      "Once per day",
      "Twice per day",
      "Three times per day",
      "Four times per day",
      "Every other day",
      "Every 3 hours",
      "Every 4 hours",
      "Every 6 hours",
      "Every 8 hours",
      "Every 12 hours"
    ].map{|x| x.upcase}

  def initialize(file_path)
    @file_path = file_path
    self.class.send(:attr_accessor, "file_path")

    self.class.send(:attr_accessor, "raw_text")
    self.class.send(:attr_accessor, "amount")
    self.class.send(:attr_accessor, "units")
    self.class.send(:attr_accessor, "frequency")
    self.class.send(:attr_accessor, "delivery")
    self.class.send(:attr_accessor, "drug_name")
  end

  def convert_to_text
    @files = File.new(file_path)
    @data  = OcrSpace::FilePost.post('/parse/image', body: { apikey: "0ad729224588957", language: "eng", isOverlayRequired: false, file: @files })
    if @data.parsed_response["ErrorMessage"].present?
      raise StandardError.new(@data.parsed_response["ErrorMessage"][0]) and return
    end

    self.raw_text = @data.parsed_response['ParsedResults'][0]["ParsedText"].gsub(/\r|\n/, "")
    return self.raw_text
  end

  # def convert_to_text_from_base64(base64)
  #   puts "STARTING..."
  #   @data  = OcrSpace::FilePost.post('/parse/image', body: { apikey: "0ad729224588957", language: "eng", isOverlayRequired: false, base64image: base64})
  #
  #   puts "\n\n\n@data: #{@data.inspect}\n\n\n"
  #
  #   if @data.parsed_response["ParsedResults"][0]["ErrorMessage"].present?
  #     raise StandardError.new(@data.parsed_response["ParsedResults"][0]["ErrorMessage"]) and return
  #   end
  #
  #   puts "\n\n\n@data: #{@data.inspect}\n\n\n"
  #
  #   self.raw_text = @data.parsed_response['ParsedResults'][0]["ParsedText"].gsub(/\r|\n/, "")
  #   return self.raw_text
  # end

  def convert_to_text_from_base64(base64)

    base64.gsub!("\r\n", "")
    $redis_pool.with {|redis| redis.set("base64", base64)}

    puts "STARTING..."

    path = Rails.root.join('public') + "#{SecureRandom.hex}.jpeg"
    puts "PATH IS: #{path}"
    File.open(path, "wb+") do |f|
      f.write(Base64.decode64(base64['data:image/jpeg;base64,'.length..-1]))
    end

    # file = Tempfile.new(["parse_from_mobile", ".jpeg"])
    # file.binmode
    # decoded = Base64.decode64(base64['data:image/jpeg;base64,'.length..-1])
    # file.write(decoded)

    puts "File written..."

    file = File.new(path)

    # @data  = OcrSpace::FilePost.post('/parse/image', body: { apikey: "0ad729224588957", language: "eng", isOverlayRequired: false, file: file})
    @data  = OcrSpace::FilePost.post('/parse/image', body: { apikey: "0ad729224588957", language: "eng", isOverlayRequired: false, base64image: base64})

    puts "\n\n\n@data: #{@data.inspect}\n\n\n"

    puts "\n\n\nFile size: #{file.size}\n\n\n"
    File.delete(path)

    if @data.parsed_response["ParsedResults"] && @data.parsed_response["ParsedResults"][0] && @data.parsed_response["ParsedResults"][0]["ErrorMessage"].present?
      raise StandardError.new(@data.parsed_response["ParsedResults"][0]["ErrorMessage"]) and return
    end


    if @data.parsed_response["ErrorMessage"].present?
      raise StandardError.new(@data.parsed_response["ErrorMessage"]) and return
    end


    self.raw_text = @data.parsed_response['ParsedResults'][0]["ParsedText"].gsub(/\r|\n/, "")
    return self.raw_text
  end

  def parse
    self.extract_drug_name
    self.extract_frequency
    self.extract_amount_and_units
    self.extract_delivery
  end

  def extract_frequency
    freq_regex_match = get_from_regex(/(EVERY (((\d)+ (\w)+)|((\w)+)))|((\w)+ DAILY)|(AT (\w)+)/)

    if not freq_regex_match.nil?
      freq_regex_match = freq_regex_match.gsub("DAILY", "PER DAY")
      freq_regex_match = freq_regex_match.gsub("NIGHT", "DAY")
      freq_regex_match = freq_regex_match.gsub("EVERY DAY", "ONCE PER DAY")
      freq_regex_match = freq_regex_match.gsub("AT BEDTIME", "ONCE PER DAY")

      closest_match_index = nil
      closest_match_amt = 0

      @@frequencies.each_with_index do |freq, freq_index|
        match_amt = levenshtein_distance(freq, freq_regex_match)

        if match_amt < closest_match_amt or closest_match_index.nil?
          closest_match_index = freq_index
          closest_match_amt = match_amt

          if closest_match_amt == 0 then break end
        end
      end

      freq_regex_match = @@frequencies[closest_match_index]
    end

    self.frequency = freq_regex_match
  end

  def extract_amount_and_units
    units_regex = /(?<amount>(((\d)-(\d))|((\d)+))) (?<unit>(#{@@units_normalized.join('|')})(S){0,1})/

    list_match = get_from_regex(units_regex, true)

    self.amount = list_match[:amount]
    self.units = list_match[:unit]
  end

  def extract_delivery
    self.delivery = get_from_regex(/(BY MOUTH)|(SWALLOW (\w)+)/)

    if not self.delivery.nil? and (self.delivery.include? "MOUTH" or self.delivery.include? "SWALLOW")
      self.delivery = @@administrations[0]
    end
  end

  def extract_drug_name
    $drug_list = []
    processed_drugs_file = Rails.root.join("lib", "drugs_processed.txt")
    File.open(processed_drugs_file, "r") do |f|
      f.each_line do |line|
        $drug_list.push(line.upcase.squeeze(" ").strip)
      end
    end

    puts "extract_drug_name#self.raw_text: #{self.raw_text}"
    str_split = self.raw_text.split()
    for word in str_split
      word = word.strip
      puts "|#{word}|"
      result = find_drug_name_match(word)
      if result
        self.drug_name = result
        return self.drug_name
      end
    end

    return nil
  end

  #----------------------------------------------------------------------------

  private

  def get_from_regex(r1, match_list=false)

    raw_text_normalized = self.raw_text.upcase

    puts "self.raw_text; #{raw_text_normalized.inspect}"
    match = r1.match(raw_text_normalized)

    if !match
      return nil
    else
      if match_list
        return match
      else
        return match[0]
      end
    end
  end


  def find_drug_name_match(str1)
    for drug_name in $drug_list
      if drug_name.strip.downcase == str1.strip.downcase
        return drug_name.strip.downcase.capitalize
      end
    end

    return nil
  end

  #----------------------------------------------------------------------------
end
