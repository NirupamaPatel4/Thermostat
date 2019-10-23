class Reading < ApplicationRecord
  belongs_to :thermostat

  validates_presence_of :thermostat_id

  def self.call(thermostat_id, reading)
    new.call(thermostat_id, reading)
  end

  def call(thermostat_id, reading)
    reading_id = SecureRandom.uuid
    reading[:thermostat_id] = thermostat_id
    reading[:reading_id] = reading_id
    Rails.cache.write("reading_#{reading_id}", reading.to_h)

    ThermostatWorker.perform_async(reading_id)
    reading
  end

  def self.fetch(reading_id)
    Rails.cache.fetch("reading_#{reading_id}") do
      Reading.where(reading_id: reading_id).try(:last)
    end
  end
end
