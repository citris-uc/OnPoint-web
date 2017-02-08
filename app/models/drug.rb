class Drug
  include HTTParty

  def initialize(rxcui)
    @rxcui = rxcui
    self.class.send(:attr_accessor, "rxcui")

    @names = []
    self.class.send(:attr_accessor, "names")

    @codes = []
    self.class.send(:attr_accessor, "codes")

    @properties = []
    self.class.send(:attr_accessor, "properties")

    @images = []
    self.class.send(:attr_accessor, "images")

    @terms  = []
    self.class.send(:attr_accessor, "terms")

    @sbd = []
    self.class.send(:attr_accessor, "sbd")
  end

  def get_all(from_cache = false)
    drug_hash = {}
    $redis_pool.with do |redis|
      drug_json = redis.get("drugs:#{@rxcui}")
      drug_hash = JSON.parse(drug_json || "{}").with_indifferent_access
    end

    # Always query API endpoint if no data in the cache or cache specifically false
    if drug_hash.blank? || from_cache == false
      self.get()
      # self.get_images()
      # self.get_terms()
      self.related()

      $redis_pool.with do |redis|
        redis.set("drugs:#{@rxcui}", self.to_json)
      end

      return self
    else
      self.names      = drug_hash["names"]
      self.properties = drug_hash["properties"]
      self.images     = drug_hash["images"]
      self.terms      = drug_hash["terms"]
      self.sbd        = drug_hash["sbd"]

      return self
    end
  end

  # https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=lortab
  # See: https://rxnav.nlm.nih.gov/RxNormAPIs.html#uLink=RxNorm_REST_getApproximateMatch
  # Try lortab or zestril
  # NOTE: We'll try to use /displaynames autocomplete to make the search term more honed.
  def self.find_by_name(name)
    req = self.get("https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=#{name}", {})
    candidates = req.parsed_response["approximateGroup"]["candidate"]

    # Candidates come with a score and a rank. We select and return all candidates with rank=1
    return nil if candidates.blank?
    return candidates.find_all {|c| c["rank"] == "1"}.uniq {|c| c["rxcui"]}
  end

  # https://rxnav.nlm.nih.gov/REST/rxcui/856999/allProperties.json?prop=all
  # See: https://rxnav.nlm.nih.gov/RxNormAPIs.html#uLink=RxNorm_REST_getAllProperties
  # Try 856999 (APAP 325 MG / hydrocodone bitartrate 10 MG Oral Tablet)...
  # or 196472 (zestril)
  def get
    orig_req = self.class.get("https://rxnav.nlm.nih.gov/REST/rxcui/#{@rxcui}/allProperties.json?prop=all", {})
    req = orig_req["propConceptGroup"]["propConcept"]
    self.properties = req.find_all {|prop| prop["propCategory"] == "ATTRIBUTES"}
    self.names      = req.find_all {|prop| prop["propCategory"] == "NAMES"}
    return orig_req
  end

  # See https://rxnav.nlm.nih.gov/RxNormAPIs.html#uLink=RxNorm_REST_getRelatedByType
  # The related term types endpoint will help us get the branded drug information
  # from search results that match on precise ingredient or a clinical drug component.
  # E.g. searching for hydrocodone returns a well-defined ingredient, but very little
  # information on the branded drugs. You need to use /related for that...
  # See also https://rxnav.nlm.nih.gov/REST/allconcepts.json?tty=SBD
  def related
    orig_req = self.class.get("https://rxnav.nlm.nih.gov/REST/rxcui/#{@rxcui}/related.json?tty=SBD", {})
    self.sbd = orig_req["relatedGroup"]["conceptGroup"][0]["conceptProperties"]
    return orig_req
  end

  # NOTE: Codes is such a large object that we'll fetch them separately... if needed.
  def get_codes
    orig_req   = self.class.get("https://rxnav.nlm.nih.gov/REST/rxcui/#{@rxcui}/allProperties.json?prop=all", {})
    req        = orig_req["propConceptGroup"]["propConcept"]
    self.codes = req.find_all {|prop| prop["propCategory"] == "CODES"}
    return orig_req
  end

  # Try https://rximage.nlm.nih.gov/api/rximage/1/rxnav?rxcui=856999
  # "replyStatus": {
  # "success": true,
  # "date": "2017-01-11 12:27:31 GMT",
  # "imageCount": 1,
  # "totalImageCount": 1,
  # "matchedTerms": {
  # "rxcui": "856999"
  # }
  # },
  # "nlmRxImages": []
  # Also see RxImage API: https://lhncbc.nlm.nih.gov/rximage-api
  # and https://rximage.nlm.nih.gov/docs/doku.php?id=parameter:rxcui
  # TRY: http://localhost:5000/api/v0/drugs/rxcui?rxcui=352050
  def get_images
    orig_req = self.class.get("https://rximage.nlm.nih.gov/api/rximage/1/rxnav?rxcui=#{@rxcui}")
    req = orig_req["nlmRxImages"]
    req.each do |img|
      self.images << img
    end
    return orig_req
  end

  # Try https://rxnav.nlm.nih.gov/REST/RxTerms/rxcui/198440/allinfo.json
  # "rxtermsProperties": {
  # "brandName": "",
  # "displayName": "Acetaminophen (Oral Pill)",
  # "synonym": "APAP",
  # "fullName": "Acetaminophen 500 MG Oral Tablet",
  # "fullGenericName": "Acetaminophen 500 MG Oral Tablet",
  # "strength": "500 mg",
  # "rxtermsDoseForm": "Tab",
  # "route": "Oral Pill",
  # "termType": "SCD",
  # "rxcui": "198440",
  # "genericRxcui": "0",
  # "rxnormDoseForm": "Oral Tablet",
  # "suppress": ""
  # }
  # }
  # Also see https://rxnav.nlm.nih.gov/RxTermsAPIs.html#
  # The RxTerms API is a web service for accessing the current RxTerms data set. No license is needed to use the RxTerms API.
  # Returns {"brandName"=>"", "displayName"=>"Acetaminophen/HYDROcodone (Oral Pill)", "synonym"=>"APAP", "fullName"=>"Acetaminophen 325 MG / Hydrocodone Bitartrate 10 MG Oral Tablet", "fullGenericName"=>"Acetaminophen 325 MG / Hydrocodone Bitartrate 10 MG Oral Tablet", "strength"=>"325-10 mg", "rxtermsDoseForm"=>"Tab", "route"=>"Oral Pill", "termType"=>"SCD", "rxcui"=>"856999", "genericRxcui"=>"0", "rxnormDoseForm"=>"Oral Tablet", "suppress"=>""}
  def get_terms
    orig_req = self.class.get("https://rxnav.nlm.nih.gov/REST/RxTerms/rxcui/#{@rxcui}/allinfo.json")
    self.terms = orig_req["rxtermsProperties"]
    return orig_req
  end

  # See: https://dailymed.nlm.nih.gov/dailymed/webservices-help/v2/rxcuis_api.cfm#JSON
  # for more.
  def self.find_by_query_and_dailymed(query)
    data = []

    req = self.get("https://dailymed.nlm.nih.gov/dailymed/services/v2/rxcuis.json?rxstring=#{query}")


    data += req["data"]
    next_page_url = req["metadata"]["next_page_url"]
    while next_page_url != "null"
      req = self.get(next_page_url)
      data += req["data"]
      next_page_url = req["metadata"]["next_page_url"]
    end

    return data
  end


  #----------------------------------------------------------------------------

  # TODO
  # def self.autocomplete
  #   terms = []
  #   $redis_pool.with do |redis|
  #     terms = redis.get("drugs:autocomplete")
  #     if terms.present?
  #       terms = JSON.parse(terms)
  #     else
  #       read = File.open( File.join(Rails.root, "lib", "displaynames.json") ).read
  #       terms = JSON.parse(read)["displayTermsList"]["term"]
  #       redis.set("drugs:autocomplete", terms.to_json)
  #     end
  #   end
  #
  #   return terms
  # end
end
