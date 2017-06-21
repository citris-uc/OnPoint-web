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
    self.extract_amount
    self.extract_delivery
  end

  def extract_frequency
    self.frequency = get_from_regex(/(EVERY (((\d)+ (\w)+)|((\w)+)))|((\w)+ DAILY)|(AT (\w)+)/)
  end

  def extract_amount
    self.amount = get_from_regex(/(((\d)-(\d))|((\d)+)) (TABLET|CAPSULE)(S){0,1}/)
  end

  def extract_delivery
    self.delivery =  get_from_regex(/(BY MOUTH)|(SWALLOW (\w)+)/)
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

  def get_from_regex(r1)
    puts "self.raw_text; #{self.raw_text.inspect}"
    match = r1.match(self.raw_text)

    if !match
      return nil
    else
      return match[0]
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
