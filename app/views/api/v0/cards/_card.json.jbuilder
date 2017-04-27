if card["object_type"] == "medication_schedule"
  json.medications_length card["medication_schedule"]["medications"] && card["medication_schedule"]["medications"].keys.length
  json.description card["medication_schedule"]["medications"] ? "" : "You don't have any medications for this slot"

  # ms = Slot.new(@uid, card["object_id"])
  # ms.get()
  # json.schedule ms.data
  json.schedule card["medication_schedule"]
  json.status   card["status"]

  t = Time.zone.parse(card["medication_schedule"]["time"])
  if (date == Time.zone.now.strftime("%F") && Time.zone.now > t + 2.hours)
    json.upcoming false
  else
    json.upcoming true
  end

else
  json.appointment card["appointment"]
end

json.taken_medications card["taken_medications"].try(:join, ", ")
json.skipped_medications card["skipped_medications"].try(:join, ", ")

json.taken card["taken"]
json.skipped card["skipped"]
json.completed card["completed"]

json.object_id card["object_id"]
json.object_type card["object_type"]

json.date card["date"]
