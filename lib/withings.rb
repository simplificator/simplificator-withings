require 'httparty'
require 'cgi'

%w(base notification_description connection measurement_group error user).each do |part|
  require File.join(File.dirname(__FILE__), 'withings', part)
end
