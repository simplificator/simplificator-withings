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

  def self.get_request(path, params)
    response = self.get(path, :query => params)
    verify_response!(response, path, params)
  end

  # merges params with authentication hash
  def get_request(path, params)
    
    oauth_signature_parameters = {
      :oauth_consumer_key => '460e66920e42d80745001f066f1d62d0d348e20369b87150cb63fbeb04ecc01',
      :oauth_nonce => oauth_nonce,
      :oauth_signature_method => oauth_signature_method,
      :oauth_timestamp => oauth_timestamp,
      :oauth_version => oauth_version,
      :userid => @user.user_id
    }
    
    params = params.merge(oauth_signature_parameters)
    
    p "signature: #{oauth_signature('GET', self.class.base_uri + path, params)}"
    params = params.merge({
      :oauth_signature => oauth_signature('GET', self.class.base_uri + path, params),
      :oauth_token => '284948c9b4b9cce1cc76bbb77283431d9bbb9b46beddfccb79241cc12',
    })
    p params
    response = self.class.get(path, :query => params)
    self.class.verify_response!(response, path, params)
  end
  

  protected
  def oauth_timestamp
    Time.now.to_i
  end
  
  def oauth_version
    '1.0'
  end
  
  def oauth_signature_method
    'HMAC-SHA1'
  end
  
  # A random hex value
  def oauth_nonce
    rand(10 ** 30).to_s.rjust(30,'0')
  end
  
  def oauth_signature(method, url, params)
    # oauth signing is picky with sorting (based on a digest)
    params = params.to_a.map() do |item| 
      [item.first.to_s, item.last]
    end.sort
    
    param_string = params.map() {|key, value| "#{key}=#{value}"}.join('&')
    base_string = [method, url, param_string].join('&')
    base_string = CGI.escape(base_string)
    
    secret = ['8bcc225e05ccc62d6d5be8c32f535c73c9440f7688b4fd0280562ee687149b', '02f01f0e60182684676644ddbef2638e8e4de909f776340e1b5dd612dcbf'].join('&')
    
    
    digest = HMAC::SHA1.digest(secret, base_string)
    
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


#development:
#  key: 460e66920e42d80745001f066f1d62d0d348e20369b87150cb63fbeb04ecc01
#  secret: 8bcc225e05ccc62d6d5be8c32f535c73c9440f7688b4fd0280562ee687149b

#http://wbsapi.withings.net/measure?action=getmeas&
#oauth_consumer_key=7e563166232c6821742b4c277350494a455f392b353e5d49712a34762a&
#oauth_nonce=f22d74f2209ddf0c6558a47c02841fb1&
#oauth_signature=yAF9SgZa09SPl3H1Y5aAoXgyauc=&
#oauth_token=c68567f1760552958d713e92088db9f5c5189754dfe4e92068971f4e25d64&
#oauth_version=1.0&
#userid=1229

#User: Tobias Miesel
#user_id: 666088
#oauth_token: 284948c9b4b9cce1cc76bbb77283431d9bbb9b46beddfccb79241cc12
#oauth_token_secret: 02f01f0e60182684676644ddbef2638e8e4de909f776340e1b5dd612dcbf