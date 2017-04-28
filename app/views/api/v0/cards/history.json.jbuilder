json.dates @dates do |date, cards|
  json.date date
  json.cards cards.data do |card|
    json.id card[0]

    json.partial! "api/v0/cards/card", :card => card[1], :date => date
  end
end

json.end_date_string @end_date_string
