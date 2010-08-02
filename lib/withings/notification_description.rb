class Withings::NotificationDescription
  attr_reader :callback_url, :description, :expires_at
  def initialize(params = {})
    params = params.stringify_keys
    @callback_url = params['callbackurl']
    @description = params['comment']
    @expires_at = Time.at(params['expires'])
  end

  def to_s
    "[Notification #{self.callback_url} / #{self.description}, #{self.expires_at}]"
  end
end