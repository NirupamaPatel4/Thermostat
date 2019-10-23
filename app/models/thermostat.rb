class Thermostat < ApplicationRecord
  belongs_to :location
  has_many :readings, class_name: "Reading", dependent: :destroy

  def save_reading(params)
    params[:number] = (Rails.cache.read("household_#{location.id}_reading_no").try(:to_i) || location.thermostats.map(&:readings).count) + 1
    reading = Reading.call(id, params)
    save_stats(reading)
    reading
  end

  def fetch_stats
    {
      temperature: { avg: average_temperature.round(2), min: minimum_temperature, max: maximum_temperature },
      humidity: { avg: average_humidity.round(2), min: minimum_humidity, max: maximum_humidity },
      battery_charge: { avg: average_battery_charge.round(2), min: minimum_battery_charge, max: maximum_battery_charge }
    }
  end

  private

  def average_temperature
    Rails.cache.fetch("average_temperature_#{id}") do
      readings.average(:temperature)
    end
  end

  def minimum_temperature
    Rails.cache.fetch("minimum_temperature_#{id}") do
      readings.minimum(:temperature)
    end
  end

  def maximum_temperature
    Rails.cache.fetch("maximum_temperature_#{id}") do
      readings.maximum(:temperature)
    end
  end

  def average_humidity
    Rails.cache.fetch("average_humidity_#{id}") do
      readings.average(:humidity)
    end
  end

  def minimum_humidity
    Rails.cache.fetch("minimum_humidity_#{id}") do
      readings.minimum(:humidity)
    end
  end

  def maximum_humidity
    Rails.cache.fetch("maximum_humidity_#{id}") do
      readings.maximum(:humidity)
    end
  end

  def average_battery_charge
    Rails.cache.fetch("average_battery_charge_#{id}") do
      readings.average(:battery_charge)
    end
  end

  def minimum_battery_charge
    Rails.cache.fetch("minimum_battery_charge_#{id}") do
      readings.minimum(:battery_charge)
    end
  end

  def maximum_battery_charge
    Rails.cache.fetch("maximum_battery_charge_#{id}") do
      readings.maximum(:battery_charge)
    end
  end

  def save_stats(reading)
    @no_of_readings = reading[:number]
    Rails.cache.write("household_#{location.id}_reading_no", @no_of_readings)

    save_temperature_stats(reading[:temperature])
    save_humidity_stats(reading[:humidity])
    save_battery_charge_stats(reading[:battery_charge])
  end

  def save_temperature_stats(temperature)
    average_temperature_new = (average_temperature + temperature).try(:to_f) / @no_of_readings
    minimum_temperature_new = minimum_temperature < temperature ? minimum_temperature : temperature
    maximum_temperature_new = maximum_temperature > temperature ? maximum_temperature : temperature

    Rails.cache.write_multi(
      "average_temperature_#{id}": average_temperature_new,
      "minimum_temperature_#{id}": minimum_temperature_new,
      "maximum_temperature_#{id}": maximum_temperature_new
    )
  end

  def save_humidity_stats(humidity)
    average_humidity_new = (average_humidity + humidity).try(:to_f) / @no_of_readings
    minimum_humidity_new = minimum_humidity < humidity ? minimum_humidity : humidity
    maximum_humidity_new = maximum_humidity > humidity ? maximum_humidity : humidity

    Rails.cache.write_multi(
      "average_humidity_#{id}": average_humidity_new,
      "minimum_humidity_#{id}": minimum_humidity_new,
      "maximum_humidity_#{id}": maximum_humidity_new
    )
  end

  def save_battery_charge_stats(battery_charge)
    average_battery_charge_new = (average_battery_charge + battery_charge).try(:to_f) / @no_of_readings
    minimum_battery_charge_new = minimum_battery_charge < battery_charge ? minimum_battery_charge : battery_charge
    maximum_battery_charge_new = maximum_battery_charge > battery_charge ? maximum_battery_charge : battery_charge

    Rails.cache.write_multi(
      "average_battery_charge_#{id}": average_battery_charge_new,
      "minimum_battery_charge_#{id}": minimum_battery_charge_new,
      "maximum_battery_charge_#{id}": maximum_battery_charge_new
    )
  end
end
