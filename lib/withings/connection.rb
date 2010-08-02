class Withings::Connection
  include HTTParty
  base_uri 'wbsapi.withings.net'
  format :json

  attr_reader :user
  def initialize(user)
    @user = user
  end

  def self.get_request(path, params)
    response = self.get(path, :query => params)
    verify_response!(response)
  end

  def get_request(path, params)
    response = self.class.get(path, :query => params.merge(:publickey => user.public_key, :userid => user.user_id))
    self.class.verify_response!(response)
  end

  protected
  def self.verify_response!(response)
    if response['status'] == 0
      response['body'] || response['status']
    else
      raise ApiError.new(response['status'])
    end

  end

end