json.title "Medication Reminder"

if card["object_type"] == "medication_schedule"
  json.medications_length card["medication_schedule"]["medications"].keys.length
  json.schedule card["medication_schedule"]
else
  json.appointment card["appointment"]
end


json.missed card["missed"]
json.completed card["completed"]

json.object_id card["object_id"]
json.object_type card["object_type"]
