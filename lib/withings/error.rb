class Withings::ApiError < StandardError
  STATUS_CODES = {
    100	  => "The hash is missing, invalid, or does not match the provided email",
    247	  => "The userid is either absent or incorrect",
    250	  => "The userid and publickey provided do not match, or the user does not share its data",
    264	  => "The email address provided is either unknown or invalid",
    293	  => "The callback URL is either absent or incorrect",
    294	  => "No such subscription could be deleted",
    304	  => "The comment is either absent or incorrect",
    2555	=> "An unknown error occurred",
  }

  attr_reader :status
  def initialize(status)
    super(STATUS_CODES[status] || "Undefined status code. We do not have any description about the code #{status}. If you know more, then please let me know.")
    @status = status
  end

  def to_s
    super + " - Status code: #{self.status}"
  end
end