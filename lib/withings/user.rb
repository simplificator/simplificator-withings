class Withings::User
  attr_reader :short_name, :user_id, :birthdate, :fat_method, :first_name, :last_name, :gender


  # Listing the users for this account
  # 
  def self.userlist(email, password)
    response = Withings::Connection.get_request('/account', :action => :getuserslist, :email => email)
    response['users'].map do |item|
      Withings::User.new(item)
    end
  end

  def self.info(user_id)
    response = Withings::Connection.get_request('/user', :action => :getbyuserid, :userid => user_id)
    Withings::User.new(response['users'].first.merge({'public_key' => public_key}))
  end
  
  #
  # If you create a user yourself, then the only attributes of interest (required for calls to the API) are 'user_id' and TODO: what do we need
  def initialize(params)
    params = params.stringify_keys
    @short_name = params['shortname']
    @first_name = params['firstname']
    @last_name = params['lastname']
    @user_id = params['id']                         || params['user_id']
    @share = params['ispublic']
    @birthdate = Time.at(params['birthdate']) if params['birthdate']
    @gender = params['gender'] == 0 ? :male : params['gender'] == 1 ? :female : nil
    @fat_method = params['fatmethod']
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

  def share(*devices)
    @share = devices_bitmask(devices)
    connection.get_request('/user', :action => :update, :ispublic => @share)
  end

  # sharing enabled for a device?
  def share?(device = Withings::SCALE | Withings::BLOOD_PRESSURE_MONITOR)
    @share & device
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


  #def self.once()
  #  Withings::Connection.get_request('/once', :action => :get)['once']
  #end
  
  #http://wbsapi.withings.net/measure?action=getmeas&
  # oauth_consumer_key=7e563166232c6821742b4c277350494a455f392b353e5d49712a34762a&
  #   oauth_nonce=f22d74f2209ddf0c6558a47c02841fb1&
  #   oauth_signature=yAF9SgZa09SPl3H1Y5aAoXgyauc=&
  #   oauth_signature_method=HMAC-SHA1&
  #   oauth_timestamp=1309783586&
  #   oauth_token=c68567f1760552958d713e92088db9f5c5189754dfe4e92068971f4e25d64&
  #   oauth_version=1.0&
  #   userid=1229
  #   
  #User: Tobias Miesel
  #user_id: 666088
  #oauth_token: 284948c9b4b9cce1cc76bbb77283431d9bbb9b46beddfccb79241cc12
  #oauth_token_secret: 02f01f0e60182684676644ddbef2638e8e4de909f776340e1b5dd612dcbf

end