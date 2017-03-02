json.title Card.title(card)
# json.shown_at card["shown_at"]
# json.formatted_time Time.parse(card["shown_at"]).strftime("%A, %B %d %I:%M %p")
# json.short_timestamp Card.short_timestamp(@uid, card)
# json.time_ago_in_words time_ago_in_words(Time.parse(card["shown_at"])) + " ago"
json.description Card.description(@uid, card)

if card["object_type"] == "medication_schedule"
  json.schedule Card.schedule(@uid, card)
else
  json.appointment card["appointment"]
end

json.object_id card["object_id"]
json.object_type card["object_type"]

# json.status_class Card.status_class(card)
# json.status_text Card.status_text(card)
