json.title "Medication Reminder"

if card["object_type"] == "medication_schedule"
  json.medications_length card["medication_schedule"]["medications"] && card["medication_schedule"]["medications"].keys.length
  json.description card["medication_schedule"]["medications"] ? "" : "You don't have any medications for this slot"
  json.schedule card["medication_schedule"]

  t = Time.zone.parse(card["medication_schedule"]["time"])
  if (Time.zone.now > t + 2.hours)
    json.status "past"
  else
    json.status "upcoming"
  end

else
  json.appointment card["appointment"]
end


json.missed card["missed"]
json.completed card["completed"]

json.object_id card["object_id"]
json.object_type card["object_type"]
