class ThermostatWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(reading_id)
    thermostat_reading_obj = Rails.cache.read("reading_#{reading_id}")

    unless thermostat_reading_obj.nil?
      ApplicationRecord.transaction do
        Reading.create!(thermostat_reading_obj)
        Rails.cache.delete("reading_#{reading_id}")
      end
    end
  end

end
