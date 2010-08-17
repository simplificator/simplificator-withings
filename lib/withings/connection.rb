# A convenience class for making get requests to WBS API.
# It verifies the response and raises ApiError if a call failed.
class Withings::Connection
  include HTTParty
  base_uri 'wbsapi.withings.net'
  format :json

  def initialize(user)
    @user = user
  end

  def self.get_request(path, params)
    response = self.get(path, :query => params)
    verify_response!(response, path, params)
  end

  # Merges the params with public_key and user_id for authentication.
  def get_request(path, params)
    params =  params.merge(:publickey => @user.public_key, :userid => @user.user_id)
    response = self.class.get(path, :query => params)
    self.class.verify_response!(response, path, params)
  end

  protected
  # Verifies the status code in the JSON response and returns either the body element or raises ApiError
  def self.verify_response!(response, path, params)
    if response['status'] == 0
      response['body'] || response['status']
    else
      raise Withings::ApiError.new(response['status'], path, params)
    end
  end
end