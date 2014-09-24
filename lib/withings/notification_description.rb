class Withings::NotificationDescription
  attr_reader :callback_url, :expires_at # :description
  def initialize(params = {})
    params = params.stringify_keys
    @callback_url = params['comment']
    @expires_at = Time.at(params['expires'])
  end

  def to_s
    "[Notification #{self.callback_url}, #{self.expires_at}]"
  end
end