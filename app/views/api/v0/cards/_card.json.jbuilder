json.title Card.title(card)

if card["object_type"] == "medication_schedule"
  json.medications_length card["medication_schedule"]["medications"].keys.length
  json.schedule card["medication_schedule"] # Card.schedule(@uid, card)
else
  json.appointment card["appointment"]
end

json.object_id card["object_id"]
json.object_type card["object_type"]
