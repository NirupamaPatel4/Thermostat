require 'rails_helper'

RSpec.describe Api::ReadingsController, type: :controller do

  let(:location) { create(:location) }
  let(:thermostat) { create(:thermostat, location: location) }
  let(:reading) { create(:reading, thermostat: thermostat) }
  let(:headers) do
    {
      "Authorization" => thermostat.household_token
    }
  end

  describe 'create' do
    context "with invalid household_token" do
      let(:headers1) do
        {
            "Authorization" => SecureRandom.hex
        }
      end
      it "returns unauthorized error" do
        request.headers.merge! headers1
        process :create, method: :post, params: { "humidity": 2.4, "battery_charge": 78 }
        expect(JSON.parse(response.body)["errors"]).to eq({"unauthorized"=>"Couldn't find any Thermostat for the given token."},)
      end

    end

    context "with invalid attributes" do
      it "does not invoke Thermostat model's save_reading method due to temperature missing validated request params" do
        request.headers.merge! headers
        process :create, method: :post, params: { "humidity": 2.4, "battery_charge": 78 }
        expect(JSON.parse(response.body)["message"]).to eq("param is missing or the value is empty: temperature")
      end

      it "does not invoke Thermostat model's save_reading method due to humidity missing validated request params" do
        request.headers.merge! headers
        process :create, method: :post, params: { "temperature": 98, "battery_charge": 78 }
        expect(JSON.parse(response.body)["message"]).to eq("param is missing or the value is empty: humidity")
      end

      it "does not invoke Thermostat model's save_reading method due to battery_charge missing validated request params" do
        request.headers.merge! headers
        process :create, method: :post, params: { "temperature": 98, "humidity": 2.4 }
        expect(JSON.parse(response.body)["message"]).to eq("param is missing or the value is empty: battery_charge")
      end
    end

    context "with valid attributes" do
      before do
        allow_any_instance_of(Thermostat).to receive(:save_reading).and_return(reading)
      end

      it "invokes Thermostat model's save_reading method" do
        request.headers.merge! headers
        expect_any_instance_of(Thermostat).to receive(:save_reading)
        process :create, method: :post, params: { "temperature": reading.temperature, "humidity": reading.humidity, "battery_charge": reading.battery_charge }
        expect(JSON.parse(response.body)['thermostat_id']).to eq(reading.thermostat.id)
        expect(JSON.parse(response.body)['reading_id']).to eq(reading.reading_id)
        expect(JSON.parse(response.body)['temperature']).to eq(reading.temperature)
        expect(JSON.parse(response.body)['humidity']).to eq(reading.humidity)
        expect(JSON.parse(response.body)['battery_charge']).to eq(reading.battery_charge)
      end
    end

  end

  describe 'show' do
    it "invokes Reading model's fetch method and returns reading" do
      allow(Reading).to receive(:fetch).and_return(reading)
      request.headers.merge! headers

      expect(Reading).to receive(:fetch)
      process :show, method: :get, params: { id: reading.reading_id }

      expect(JSON.parse(response.body)['thermostat_id']).to eq(reading.thermostat.id)
      expect(JSON.parse(response.body)['reading_id']).to eq(reading.reading_id)
      expect(JSON.parse(response.body)['temperature']).to eq(reading.temperature)
      expect(JSON.parse(response.body)['humidity']).to eq(reading.humidity)
      expect(JSON.parse(response.body)['battery_charge']).to eq(reading.battery_charge)
    end

    it "vlaidates access" do
      thermostat1 = create(:thermostat, location: location)
      reading1 = create(:reading, thermostat: thermostat1)
      allow(Reading).to receive(:fetch).and_return(reading1)
      request.headers.merge! headers

      expect(Reading).to receive(:fetch)
      process :show, method: :get, params: { id: reading1.reading_id }

      expect(JSON.parse(response.body)['errors']).to eq({"unauthorized"=>"Couldn't find any Thermostat for the given token."})
    end

  end
end