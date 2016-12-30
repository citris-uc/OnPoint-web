json.title Card.title(card)
json.shown_at card["shown_at"]
json.formatted_time Time.parse(card["shown_at"]).strftime("%A, %B %d %I:%M %p")
json.time_ago_in_words time_ago_in_words(Time.parse(card["shown_at"])) + " ago"
json.description "TODO"

json.object_id card["object_id"]
json.object_type card["object_type"]
