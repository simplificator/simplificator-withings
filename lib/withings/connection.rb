# A convenience class for making get requests to WBS API.
# It verifies the response and raises ApiError if a call failed.
class Withings::Connection
  include HTTParty
  if ENV.has_key?('http_proxy')
    uri = URI.parse(ENV['http_proxy'])
    http_proxy uri.host, uri.port
  end

  base_uri 'wbsapi.withings.net'
  format :json

  def initialize(user)
    @user = user
  end

  def self.get_request(path, token, secret, params)
    signature = Withings::Connection.sign(base_uri + path, params, token, secret)
    params.merge!({:oauth_signature => signature})

    response = self.get(path, :query => params)
    verify_response!(response, path, params)
  end

  def get_request(path, params)
    params.merge!({:userid => @user.user_id})
    self.class.get_request(path, @user.oauth_token, @user.oauth_token_secret, params)
  end

  protected

  def self.sign(url, params, token, secret)
    params.merge!({
      :oauth_consumer_key => Withings.consumer_key,
      :oauth_nonce => oauth_nonce,
      :oauth_signature_method => oauth_signature_method,
      :oauth_timestamp => oauth_timestamp,
      :oauth_version => oauth_version,
      :oauth_token => token
    })
    calculate_oauth_signature('GET', url, params, secret)
  end

  def self.oauth_timestamp
    Time.now.to_i
  end

  def self.oauth_version
    '1.0'
  end

  def self.oauth_signature_method
    'HMAC-SHA1'
  end

  def self.oauth_nonce
    rand(10 ** 30).to_s(16)
  end

  def self.calculate_oauth_signature(method, url, params, oauth_token_secret)
    # oauth signing is picky with sorting (based on a digest)
    params = params.to_a.map() do |item|
      [item.first.to_s, CGI.escape(item.last.to_s)]
    end.sort

    param_string = params.map() {|key, value| "#{key}=#{value}"}.join('&')
    base_string = [method, CGI.escape(url), CGI.escape(param_string)].join('&')

    secret = [Withings.consumer_secret, oauth_token_secret].join('&')

    digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), secret, base_string)
    Base64.encode64(digest).chomp.gsub( /\n/, '' )
  end

  # Verifies the status code in the JSON response and returns either the body element or raises ApiError
  def self.verify_response!(response, path, params)
    if response['status'] == 0
      response['body'] || response['status']
    else
      raise Withings::ApiError.new(response['status'], path, params)
    end
  end
end
