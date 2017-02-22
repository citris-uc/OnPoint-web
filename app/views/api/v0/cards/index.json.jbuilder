json.cards @cards do |id, card|
  next unless Card.should_display(@uid, card)
  json.id id

  json.partial! "api/v0/cards/card", :card => card
end
