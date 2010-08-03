class Withings::User
  attr_reader :short_name, :public_key, :user_id, :birthdate, :fat_method, :first_name, :last_name, :gender

  # Authenticate a user by email/password
  #
  def self.authenticate(email, password)
    response = Connection.get_request('/account', :action => :getuserslist, :email => email, :hash => auth_hash(email, password))
    User.new(response['users'].first)
  end

  def self.info(user_id, public_key)
    response = Connection.get_request('/user', :action => :getbyuserid, :userid => user_id, :publickey => public_key)
    User.new(response['users'].first)
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
    @share = params['ispublic'] == 1 ? true : false
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
    NotificationDescription.new(response.merge(:callbackurl => callback_url))
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
  #
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

    response = connection.get_request('/measure', options.merge(:action => :getmeas))
    response['measuregrps'].map do |group|
      MeasurementGroup.new(group)
    end
  end

  # enable or disable sharing
  def share=(value)
    @share = value
    connection.get_request('/user', :action => :update, :ispublic => is_public?)
  end

  # sharing enabled?
  def share?
    @share
  end

  def to_s
    "[User #{short_name} / #{:user_id} / #{sharing?}]"
  end


  protected

  def connection
    @connection ||= Connection.new(self)
  end

  def self.auth_hash(email, password)
    hashed_password = Digest::MD5.hexdigest(password)
    Digest::MD5.hexdigest("#{email}:#{hashed_password}:#{once}")
  end

  def self.once()
    Connection.get_request('/once', :action => :get)['once']
  end

  # convert from boolean (@share) to 1/0 as required by the API
  def is_public?
    @share ? 1 : 0
  end

end