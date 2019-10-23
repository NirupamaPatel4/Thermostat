FactoryBot.define do
  factory :thermostat do
    household_token { SecureRandom.hex }
    location_id { 1 }
  end
end
