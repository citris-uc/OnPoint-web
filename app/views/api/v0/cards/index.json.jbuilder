json.cards @cards do |id, card|
  json.id id
  json.partial! "api/v0/cards/card", :card => card
end
