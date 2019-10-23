require 'rails_helper'

RSpec.describe ThermostatWorker, type: :worker do
  let(:cache) { Rails.cache }
  let(:reading_id) { SecureRandom.uuid }
  let(:location) { create(:location) }
  let(:thermostat) { create(:thermostat, location: location) }
  let(:reading_obj) do
    {
      reading_id: reading_id,
      thermostat_id: thermostat.id,
      temperature: 44,
      humidity: 8.2,
      battery_charge: 87
    }
  end
  let(:worker_obj) { described_class.new }

  describe 'perform' do
    context 'given that the cache is populated' do
      before { Rails.cache.write("reading_#{reading_id}", reading_obj) }

      it 'should save reading obj to db and remove from redis' do
        expect(cache.exist?("reading_#{reading_id}")).to be(true)
        expect(Reading.find_by_reading_id(reading_id)).to eq(nil)
        worker_obj.perform(reading_id)
        expect(Reading.find_by_reading_id(reading_id)).not_to eq(nil)
        expect(cache.exist?("reading_#{reading_id}")).to be(false)
      end
    end

    context 'given that the cache is unpopulated' do
      before { Rails.cache.clear }

      it 'should not save reading obj' do
        expect(cache.exist?("reading_#{reading_id}")).to be(false)
        expect(Reading.find_by_reading_id(reading_id)).to eq(nil)
        worker_obj.perform(reading_id)
        expect(Reading.find_by_reading_id(reading_id)).to eq(nil)
        expect(cache.exist?("reading_#{reading_id}")).to be(false)
      end
    end
  end
end
