require 'rails_helper'

RSpec.describe Reading, type: :model do

  let(:location) { create(:location) }
  let(:thermostat) { create(:thermostat, location: location) }
  let(:cache) { Rails.cache }

  describe 'call' do
    let(:reading_id) { SecureRandom.uuid }
    let(:reading_obj) do
      {
        temperature: 44,
        humidity: 8.2,
        battery_charge: 87
      }
    end
    before do
      Rails.cache.clear
      allow(ThermostatWorker).to receive(:set) { ThermostatWorker }
      allow(SecureRandom).to receive(:uuid).and_return(reading_id)
    end

    it 'generates reading_id and invokes worker' do
      expect(ThermostatWorker).to receive(:perform_async)
      expect(cache.exist?("reading_#{reading_id}")).to be(false)
      reading = Reading.call(thermostat.id, reading_obj)

      expect(cache.exist?("reading_#{reading_id}")).to be(true)
      expect(cache.read("reading_#{reading_id}")).to eq(reading)
      expect(reading[:reading_id]).not_to eq(nil)
      expect(reading[:thermostat_id]).to eq(thermostat.id)
      expect(reading[:temperature]).to eq(reading_obj[:temperature])
      expect(reading[:humidity]).to eq(reading_obj[:humidity])
      expect(reading[:battery_charge]).to eq(reading_obj[:battery_charge])
    end
  end

  describe 'fetch' do
    let(:reading) { create(:reading, thermostat: thermostat) }

    context 'given that the cache is unpopulated' do
      before { Rails.cache.clear }

      it 'does a database lookup and returns reading object for given reading_id' do
        expect(cache.exist?("reading_#{reading.reading_id}")).to be(false)
        result = Reading.fetch(reading.reading_id)

        expect(cache.exist?("reading_#{reading.reading_id}")).to be(true)

        expect(result.thermostat_id).to eq(thermostat.id)
        expect(reading[:temperature]).to eq(result[:temperature])
        expect(reading[:humidity]).to eq(result[:humidity])
        expect(reading[:battery_charge]).to eq(result[:battery_charge])
      end
    end

  end

end
