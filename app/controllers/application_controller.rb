class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  before_action :authenticate_token!

  def thermostat
    @thermostat ||= authenticate_token!
  end

  def authenticate_token!
    thermostat = Thermostat.find_by_household_token(request_token)
    render_unauthorized if thermostat.nil?
    thermostat
  end

  def render_unauthorized(error_payload = nil)
    error_payload ||= {
      errors: {
        unauthorized: "Couldn't find any Thermostat for the given token."
      }
    }
    json_response(error_payload, :unauthorized)
  end

  def request_token
    auth_h = request.headers['Authorization']
    auth_h&.split(' ')&.last
  end
end
