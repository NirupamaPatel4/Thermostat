FactoryBot.define do
  factory :reading do
    reading_id { SecureRandom.uuid }
    number { 1 }
    temperature { 98 }
    humidity { 1.5 }
    battery_charge { 75 }
    thermostat_id { 1 }
  end
end
