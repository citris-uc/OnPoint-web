json.history @history do |k,v|
  json.taken_at v["taken_at"]
  json.skipped_at v["skipped_at"]
end
