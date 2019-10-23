require 'rails_helper'

RSpec.describe Thermostat, type: :model do

  let!(:location) { create(:location) }
  let!(:thermostat) { create(:thermostat, location: location) }
  let(:sequence) { 1 }
  let!(:reading) { create(:reading, number: sequence + 1, thermostat: thermostat) }
  let!(:reading1) { create(:reading, number: sequence + 1, thermostat: thermostat) }
  let!(:reading2) { create(:reading, number: sequence + 2, thermostat: thermostat) }

  let(:average_temperature_old) { thermostat.readings.average(:temperature) }
  let(:minimum_temperature_old) { thermostat.readings.minimum(:temperature) }
  let(:maximum_temperature_old) { thermostat.readings.maximum(:temperature) }

  let(:average_humidity_old) { thermostat.readings.average(:humidity) }
  let(:minimum_humidity_old) { thermostat.readings.minimum(:humidity) }
  let(:maximum_humidity_old) { thermostat.readings.maximum(:humidity) }

  let(:average_battery_charge_old) { thermostat.readings.average(:battery_charge) }
  let(:minimum_battery_charge_old) { thermostat.readings.minimum(:battery_charge) }
  let(:maximum_battery_charge_old) { thermostat.readings.maximum(:battery_charge) }
  let(:cache) { Rails.cache }

  before do
    Rails.cache.clear
  end

  describe 'save_reading' do
    let(:params) do
      {
        temperature: 42,
        humidity: 6.2,
        battery_charge: 97
      }
    end

    let(:params_with_sequence) do
      {
        temperature: 42,
        humidity: 6.2,
        battery_charge: 97,
        number: sequence + 1
      }
    end

    let(:expected_reading_res) do
      {
        reading_id: SecureRandom.uuid,
        thermostat_id: thermostat.id,
        number: sequence + 1,
        temperature: 42,
        humidity: 6.2,
        battery_charge: 97
      }
    end

    before do
      allow(Reading).to receive(:call).with(thermostat.id, params_with_sequence).and_return(expected_reading_res)
    end

    it 'assigns a sequence number, invokes Reading and save stats' do
      expect(cache.exist?("household_#{location.id}_reading_no")).to be(false)

      expect(cache.exist?("average_temperature_#{thermostat.id}")).to be(false)
      expect(cache.exist?("minimum_temperature_#{thermostat.id}")).to be(false)
      expect(cache.exist?("maximum_temperature_#{thermostat.id}")).to be(false)

      expect(cache.exist?("average_humidity_#{thermostat.id}")).to be(false)
      expect(cache.exist?("minimum_humidity_#{thermostat.id}")).to be(false)
      expect(cache.exist?("maximum_humidity_#{thermostat.id}")).to be(false)

      expect(cache.exist?("average_battery_charge_#{thermostat.id}")).to be(false)
      expect(cache.exist?("minimum_battery_charge_#{thermostat.id}")).to be(false)
      expect(cache.exist?("maximum_battery_charge_#{thermostat.id}")).to be(false)

      reading_res = thermostat.save_reading(params)

      expect(cache.exist?("household_#{location.id}_reading_no")).to be(true)
      expect(cache.read("household_#{location.id}_reading_no")).to eq(expected_reading_res[:number])

      expect(cache.exist?("average_temperature_#{thermostat.id}")).to be(true)
      expect(cache.read("average_temperature_#{thermostat.id}")).not_to eq(average_temperature_old)
      expect(cache.exist?("minimum_temperature_#{thermostat.id}")).to be(true)
      expect(cache.read("minimum_temperature_#{thermostat.id}")).not_to eq(minimum_temperature_old)
      expect(cache.exist?("maximum_temperature_#{thermostat.id}")).to be(true)
      expect(cache.read("maximum_temperature_#{thermostat.id}")).to eq(maximum_temperature_old)

      expect(cache.exist?("average_humidity_#{thermostat.id}")).to be(true)
      expect(cache.read("average_humidity_#{thermostat.id}")).not_to eq(average_humidity_old)
      expect(cache.exist?("minimum_humidity_#{thermostat.id}")).to be(true)
      expect(cache.read("minimum_humidity_#{thermostat.id}")).to eq(minimum_humidity_old)
      expect(cache.exist?("maximum_humidity_#{thermostat.id}")).to be(true)
      expect(cache.read("maximum_humidity_#{thermostat.id}")).not_to eq(maximum_humidity_old)

      expect(cache.exist?("average_battery_charge_#{thermostat.id}")).to be(true)
      expect(cache.read("average_battery_charge_#{thermostat.id}")).not_to eq(average_battery_charge_old)
      expect(cache.exist?("minimum_battery_charge_#{thermostat.id}")).to be(true)
      expect(cache.read("minimum_battery_charge_#{thermostat.id}")).to eq(minimum_battery_charge_old)
      expect(cache.exist?("maximum_battery_charge_#{thermostat.id}")).to be(true)
      expect(cache.read("maximum_battery_charge_#{thermostat.id}")).not_to eq(maximum_battery_charge_old)

      expect(Reading).to have_received(:call).with(thermostat.id, params_with_sequence)
      expect(reading_res).to eq(expected_reading_res)
    end

  end

  describe 'fetch_stats' do

    let!(:reading1) { create(:reading, number: sequence + 1, thermostat: thermostat) }
    let!(:reading2) { create(:reading, number: sequence + 2, thermostat: thermostat) }
    let!(:reading3) { create(:reading, number: sequence + 3, thermostat: thermostat) }

    let(:average_temperature) { thermostat.readings.average(:temperature) }
    let(:minimum_temperature) { thermostat.readings.minimum(:temperature) }
    let(:maximum_temperature) { thermostat.readings.maximum(:temperature) }

    let(:average_humidity) { thermostat.readings.average(:humidity) }
    let(:minimum_humidity) { thermostat.readings.minimum(:humidity) }
    let(:maximum_humidity) { thermostat.readings.maximum(:humidity) }

    let(:average_battery_charge) { thermostat.readings.average(:battery_charge) }
    let(:minimum_battery_charge) { thermostat.readings.minimum(:battery_charge) }
    let(:maximum_battery_charge) { thermostat.readings.maximum(:battery_charge) }

    before do
      Rails.cache.clear
    end

    it 'returns stats and saves in cache' do
      expect(cache.exist?("average_temperature_#{thermostat.id}")).to be(false)
      expect(cache.exist?("minimum_temperature_#{thermostat.id}")).to be(false)
      expect(cache.exist?("maximum_temperature_#{thermostat.id}")).to be(false)

      expect(cache.exist?("average_humidity_#{thermostat.id}")).to be(false)
      expect(cache.exist?("minimum_humidity_#{thermostat.id}")).to be(false)
      expect(cache.exist?("maximum_humidity_#{thermostat.id}")).to be(false)

      expect(cache.exist?("average_battery_charge_#{thermostat.id}")).to be(false)
      expect(cache.exist?("minimum_battery_charge_#{thermostat.id}")).to be(false)
      expect(cache.exist?("maximum_battery_charge_#{thermostat.id}")).to be(false)

      stats = thermostat.fetch_stats

      expect(stats[:temperature]).to eq({:avg=>average_temperature, :max=>maximum_temperature, :min=>minimum_temperature})
      expect(stats[:humidity]).to eq({:avg=>average_humidity, :max=>maximum_humidity, :min=>minimum_humidity})
      expect(stats[:battery_charge]).to eq({:avg=>average_battery_charge, :max=>maximum_battery_charge, :min=>minimum_battery_charge})

      expect(cache.exist?("average_temperature_#{thermostat.id}")).to be(true)
      expect(cache.exist?("minimum_temperature_#{thermostat.id}")).to be(true)
      expect(cache.exist?("maximum_temperature_#{thermostat.id}")).to be(true)

      expect(cache.exist?("average_humidity_#{thermostat.id}")).to be(true)
      expect(cache.exist?("minimum_humidity_#{thermostat.id}")).to be(true)
      expect(cache.exist?("maximum_humidity_#{thermostat.id}")).to be(true)

      expect(cache.exist?("average_battery_charge_#{thermostat.id}")).to be(true)
      expect(cache.exist?("minimum_battery_charge_#{thermostat.id}")).to be(true)
      expect(cache.exist?("maximum_battery_charge_#{thermostat.id}")).to be(true)
    end

  end
end
