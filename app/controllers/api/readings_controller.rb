# frozen_string_literal: true

module Api
  class ReadingsController < ApplicationController

    def create
      reading = thermostat.save_reading(request_params)
      json_response(reading)
    end

    def show
      reading = Reading.fetch(params[:id])
      return render_unauthorized if reading.thermostat_id != thermostat.id

      json_response(reading)
    end

    private

    def request_params
      params.require(%i[temperature humidity battery_charge])
      params.permit(:temperature, :humidity, :battery_charge)
    end
  end
end
