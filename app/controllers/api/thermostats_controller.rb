module Api
  class ThermostatsController < ApplicationController

    skip_before_action :authenticate_token!, only: :show

    def show
      thermostat = Thermostat.includes(:readings).find(params[:id])
      json_response(thermostat: thermostat, reading_ids: thermostat.try(:readings).map(&:reading_id))
    end

    def stats
      json_response(response: thermostat.fetch_stats)
    end
  end
end