class Withings::User
  attr_reader :short_name, :public_key, :user_id, :birthdate, :fat_method, :first_name, :last_name, :gender


  # Listing the users for this account
  # 
  def self.userlist(email, password)
    response = Withings::Connection.get_request('/account', :action => :getuserslist, :email => email, :hash => auth_hash(email, password))
    response['users'].map do |item|
      Withings::User.new(item)
    end
  end
  
  
  # Authenticate a user by email/password
  #
  def self.authenticate(email, password)
    $stderr.puts <<-EOS
      User.authenticate(email, pwd) has been deprecated in favour of User.userlist(email, pwd) as there is no description or guarantee 
      about the order the users are returned.
      If you need the same behaviour as before: User.userlist(email, pwd).first
    EOS
    response = Withings::Connection.get_request('/account', :action => :getuserslist, :email => email, :hash => auth_hash(email, password))
    Withings::User.new(response['users'].first)
  end

  def self.info(user_id, public_key)
    response = Withings::Connection.get_request('/user', :action => :getbyuserid, :userid => user_id, :publickey => public_key)
    Withings::User.new(response['users'].first.merge({'public_key' => public_key}))
  end


  #
  # If you create a user yourself, then the only attributes of interest (required for calls to the API) are 'user_id' and 'public_key'
  #
  def initialize(params)
    params = params.stringify_keys
    @short_name = params['shortname']
    @first_name = params['firstname']
    @last_name = params['lastname']
    @public_key = params['publickey']               || params['public_key']
    @user_id = params['id']                         || params['user_id']
    @share = params['ispublic']
    @birthdate = Time.at(params['birthdate']) if params['birthdate']
    @gender = params['gender'] == 0 ? :male : params['gender'] == 1 ? :female : nil
    @fat_method = params['fatmethod']
  end

  def subscribe_notification(callback_url, description)
    connection.get_request('/notify', :action => :subscribe, :callbackurl => callback_url, :comment => description)
  end

  def revoke_notification(callback_url)
    connection.get_request('/notify', :action => :revoke, :callbackurl => callback_url)
  end

  def describe_notification(callback_url)
    response = connection.get_request('/notify', :action => :get, :callbackurl => callback_url)
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
    devices = [Withings::SCALE, Withings::BLOOD_PRESSURE_MONITOR] if Array(devices).empty?
    @share = devices.inject('|'.to_sym)
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

  def connection
    @connection ||= Withings::Connection.new(self)
  end

  def self.auth_hash(email, password)
    hashed_password = Digest::MD5.hexdigest(password)
    Digest::MD5.hexdigest("#{email}:#{hashed_password}:#{once}")
  end

  def self.once()
    Withings::Connection.get_request('/once', :action => :get)['once']
  end

end