require 'rubygems'
require 'withings'

# All classes are name-spaced
include Withings

# A user can be authenticated with email address and password
user = User.authenticate('<YOUR EMAIL ADDRESS>', '<YOUR PASSWORD>')

# Or you can fetch details if you have the user id and public key
user = User.authenticate('<YOUR USER ID>', '<YOUR PUBLIC KEY>')

# or if you already have user id and public key, you can create ir yourself
user = User.new(:user_id => '<YOUR USER ID>', :public_key => '<YOUR PUBLIC_KEY>')

# enable/disable sharing, disabling it will reset the public key
user.share=true

# subscribe for notification for url and pass a description
user.subscribe_notification('http://foo.bar.com', 'test')

# describe the notification for a given url, this is important for expiration dates
user.describe_notification('http://foo.bar.com')

# revoke notification for an url
user.revoke_notification('http://foo.bar.com')

# list measurement groups
user.measurement_groups(:per_page => 10, :page => 1, :end_at => Time.now).join("\n")