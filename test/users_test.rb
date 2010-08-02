require 'helper'

include Withings

class UsersTest < Test::Unit::TestCase
  context 'test connection calls' do
    setup do
      @user = User.new('user_id' => 12345, 'public_key' => 67890)
    end
    should 'update user' do
      Withings::Connection.any_instance.expects(:get_request).with('/user', :action => :update, :ispublic => 1)
      @user.share = true
    end

    should 'subscribe to notification' do
      Withings::Connection.any_instance.expects(:get_request).with('/notify', :action => :subscribe, :callbackurl => 'http://schni.com', :comment => 'descri')
      @user.subscribe_to_notification('http://schni.com', 'descri')
    end

    should 'revoke notification' do
      Withings::Connection.any_instance.expects(:get_request).with('/notify', :action => :revoke, :callbackurl => 'http://schni.com')
      @user.revoke_notification('http://schni.com')
    end

    context 'describe notification' do
      setup do
        Withings::Connection.
          any_instance.expects(:get_request).with('/notify', :action => :get, :callbackurl => 'http://schni.com').
          returns({'comment' => 'blabla', 'expires' => 1234})
        @description = @user.describe_notification('http://schni.com')
      end
      should 'merge the callback url into the descripton' do
        assert_equal 'http://schni.com', @description.callback_url
      end

      should 'contain the expires_at time' do
        assert_equal Time.at(1234), @description.expires_at
      end

      should 'contain the description' do
        assert_equal 'blabla', @description.description
      end
    end
  end

  context 'authentication by email' do
    setup do
      password = 'kongking'
      email = 'king@kong.com'
      once = 'abcdef'
      hashed = Digest::MD5.hexdigest("#{email}:#{Digest::MD5.hexdigest(password)}:#{once}")
      Connection.expects(:get_request).with('/once', :action => :get).returns({'once' => once})
      Connection.expects(:get_request).with('/account', :action => :getuserslist, :email => email, :hash => hashed).
        returns({'users' => [{}]})
    end
    should 'authenticate with hashed password' do
      User.by_email('king@kong.com', 'kongking')
    end
  end

  context 'authentication by user_id' do
    setup do
      user_id = 'kongking'
      public_key = 'abcdef'
      Connection.expects(:get_request).with('/account', :action => :getbyuserid, :userid => user_id, :publickey => public_key).
        returns({'users' => [{}]})
    end
    should 'authenticate with hashed password' do
      User.by_user_id('kongking', 'abcdef')
    end
  end


  context 'constructor' do
    should 'assign short_name' do
      assert_equal 'Pascal', User.new('shortname' => 'Pascal').short_name
    end
    should 'assign first_name' do
      assert_equal 'Pascal', User.new('firstname' => 'Pascal').first_name
    end
    should 'assign last_name' do
      assert_equal 'Pascal', User.new('lastname' => 'Pascal').last_name
    end

    should 'assign public_key' do
      assert_equal '1234', User.new('publickey' => '1234').public_key
    end
    should 'assign public_key with alternative key' do
      assert_equal '1234', User.new('public_key' => '1234').public_key
    end

    should 'assign user_id' do
      assert_equal '1234', User.new('id' => '1234').user_id
    end
    should 'assign user_id with alternative key' do
      assert_equal '1234', User.new('user_id' => '1234').user_id
    end


    should 'assign share (to true)' do
      assert_equal true, User.new('ispublic' => 1).share?
    end
    should 'assign share (to false)' do
      assert_equal false, User.new('ispublic' => 0).share?
    end

    should 'assign gender (to true)' do
      assert_equal :male, User.new('gender' => 0).gender
    end
    should 'assign gender (to false)' do
      assert_equal :female, User.new('gender' => 1).gender
    end

    should 'assign fatmethod' do
      assert_equal 2, User.new('fatmethod' => 2).fat_method
    end

  end
end
