json.cards @cards do |card|
  json.id card[0]

  json.partial! "api/v0/cards/card", :card => card[1]
end
