json.dates @dates do |date, cards|
  json.date date
  json.cards cards.data do |card_id, card_hash|
    json.id card_id

    json.partial! "api/v0/cards/card", :card => card_hash, :date => date
  end
end
