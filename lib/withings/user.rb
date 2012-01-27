class Withings::User
  attr_reader :short_name, :user_id, :birthdate, :fat_method, :first_name, :last_name, :gender, :oauth_token, :oauth_token_secret

  def self.authenticate(user_id, oauth_token, oauth_token_secret)
    response = Withings::Connection.get_request('/user', oauth_token, oauth_token_secret, :action => :getbyuserid, :userid => user_id)
    user_data = response['users'].detect { |item| item['id'] == user_id }
    raise Withings::ApiError.new(2555, 'No user found', '') unless user_data
    Withings::User.new(user_data.merge({:oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret}))
  end
  
  # If you create a user yourself, then the only attributes of interest (required for calls to the API) are 'user_id' and 'oauth_token' and 'oauth_token_secret'
  def initialize(params)
    params = params.stringify_keys
    @short_name = params['shortname']
    @first_name = params['firstname']
    @last_name = params['lastname']
    @user_id = params['id']                         || params['user_id']
    @birthdate = Time.at(params['birthdate']) if params['birthdate']
    @gender = params['gender'] == 0 ? :male : params['gender'] == 1 ? :female : nil
    @fat_method = params['fatmethod']
    @oauth_token = params['oauth_token']
    @oauth_token_secret = params['oauth_token_secret']
  end
  
  def subscribe_notification(callback_url, description, device = SCALE)
    connection.get_request('/notify', :action => :subscribe, :callbackurl => callback_url, :comment => description, :appli => device)
  end

  def revoke_notification(callback_url, device = SCALE)
    connection.get_request('/notify', :action => :revoke, :callbackurl => callback_url, :appli => device)
  end

  def describe_notification(callback_url, device = SCALE)
    response = connection.get_request('/notify', :action => :get, :callbackurl => callback_url, :appli => device)
    Withings::NotificationDescription.new(response.merge(:callbackurl => callback_url))
  end


  # list measurement groups
  # The limit and offset parameters are converted to will_paginate style parameters (:per_page, :page)
  # - :per_page           (default: 100)
  # - :page               (default: 1)
  # - :category           (default: empty)
  # - :measurement_type   (default: empty)
  # - :start_at           (default: empty)
  # - :end_at             (default: empty)
  # - :last_udpated_at    (default: empty)
  # - :device             (default: empty)
  # Parameters are described in WBS api
  def measurement_groups(params = {})
    params = params.stringify_keys
    options = {:limit => 100, :offset => 0}
    options[:limit] =  params['per_page'] if params.has_key?('per_page')
    options[:offset] = ((params['page'] || 1) - 1) * options[:limit]
    options[:category] = params['category'] if params.has_key?('category')
    options[:meastype] = params['measurement_type'] if params.has_key?('measurement_type')
    options[:startdate] = params['start_at'].to_i if params['start_at']
    options[:enddate] = params['end_at'].to_i if params['end_at']
    options[:lastupdate] = params['last_updated_at'].to_i if params['last_updated_at']
    options[:devtype] = params['device'] if params['device']
    response = connection.get_request('/measure', options.merge(:action => :getmeas))
    response['measuregrps'].map do |group|
      Withings::MeasurementGroup.new(group)
    end
  end

  def to_s
    "[User #{short_name} / #{:user_id} / #{share?}]"
  end
  

  protected
  
  def devices_bitmask(*devices)
    devices = [Withings::SCALE, Withings::BLOOD_PRESSURE_MONITOR] if Array(devices).empty?
    devices.inject('|'.to_sym)
  end

  def connection
    @connection ||= Withings::Connection.new(self)
  end
  
end