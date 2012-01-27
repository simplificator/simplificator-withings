class Withings::ApiError < StandardError
  UNKNOWN_STATUS_CODE = lambda() {|status, path, params| "Unknown status code '#{status}'"}
  STATUS_CODES = {
    100	  => lambda() {|status, path, params| "The hash '#{params[:hash]}' does not match the email '#{params[:email]}'"},
    247	  => lambda() {|status, path, params| "The userid '#{params[:userid]}' is invalid"},
    249	  => lambda() {|status, path, params| "Called an action with invalid oauth credentials"},
    250	  => lambda() {|status, path, params| "The userid '#{params[:userid]}' and publickey '#{params[:publickey]}' do not match, or the user does not share its data"},
    264	  => lambda() {|status, path, params| "The email address '#{params[:email]}' is either unknown or invalid"},
    284   => lambda() {|status, path, params| "Temporary Server Error" },
    286   => lambda() {|status, path, params| "No subscription for '#{params[:callbackurl]}' was found" },
    293	  => lambda() {|status, path, params| "The callback URL '#{params[:callbackurl]}' is either unknown or invalid"},
    294	  => lambda() {|status, path, params| "Could not delete subscription for '#{params[:callbackurl]}'"},
    304	  => lambda() {|status, path, params| "The comment '#{params[:comment]}' is invalid"},
    342	  => lambda() {|status, path, params| "Specify public key"},
    343   => lambda() {|status, path, params| "No notification matching the criteria was found: '#{params[:callbackurl]}'"},
    2554	=> lambda() {|status, path, params| "Unknown action '#{params[:action]}' for '#{path}'"},
    2555	=> lambda() {|status, path, params| "An unknown error occurred"},
  }

  attr_reader :status
  def initialize(status, path, params)
    super(build_message(status, path, params))
    @status = status
  end

  def to_s
    super + " - Status code: #{self.status}"
  end


  protected

  def build_message(status, path, params)
    (STATUS_CODES[status] || UNKNOWN_STATUS_CODE).call(status, path, params)
  end
end