class AddThermostats < ActiveRecord::Migration[5.2]
  def change
    (1..3).to_a.each do |value|
      Location.create!(address: "location_#{value}")
    end

    Location.all.each do |l|
      (1..3).to_a.each do |value|
        Thermostat.create!(location: l, household_token: SecureRandom.hex)
      end
    end

  end
end
