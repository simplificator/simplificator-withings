require 'helper'

include Withings

class UsersTest < Minitest::Test

  context 'measurement_groups' do
    setup do
      @user = User.new(:user_id => 'lala')
      @returns = {'measuregrps' => []}
    end
    should 'not require parameters' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 100, :offset => 0).returns(@returns)
      @user.measurement_groups
    end
    should 'set page and current_page A' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 10, :offset => 10).returns(@returns)
      @user.measurement_groups(:page => 2, :per_page => 10)
    end
    should 'set page and current_page B' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 5, :offset => 15).returns(@returns)
      @user.measurement_groups(:page => 4, :per_page => 5)
    end
    should 'set page and current_page C' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 23, :offset => 207).returns(@returns)
      @user.measurement_groups(:page => 10, :per_page => 23)
    end

    should 'limit the category' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 100, :offset => 0, :category => 1).returns(@returns)
      @user.measurement_groups(:page => 1, :per_page => 100, :category => 1)
    end

    should 'limit the measurement_type' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 100, :offset => 0, :meastype => 1).returns(@returns)
      @user.measurement_groups(:page => 1, :per_page => 100, :measurement_type => 1)
    end

    should 'limit start at' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 100, :offset => 0, :startdate => 1234).returns(@returns)
      @user.measurement_groups(:page => 1, :start_at => Time.at(1234))
    end

    should 'limit end at' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 100, :offset => 0, :enddate => 1234).returns(@returns)
      @user.measurement_groups(:page => 1, :end_at => Time.at(1234))
    end

    should 'limit last updated at' do
      Connection.any_instance.expects(:get_request).with('/measure', :action => :getmeas, :limit => 100, :offset => 0, :lastupdate => 1234).returns(@returns)
      @user.measurement_groups(:page => 1, :last_updated_at => Time.at(1234))
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

    should 'assign user_id' do
      assert_equal '1234', User.new('id' => '1234').user_id
    end
    should 'assign user_id with alternative key' do
      assert_equal '1234', User.new('user_id' => '1234').user_id
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

  context 'authenticate' do
    context 'integer userid' do
      should 'return user' do
        Withings::Connection.stubs(:get_request).with('/user', anything(), anything(), anything()).returns({
          'users' => [
            {
              'id' => 29,
              'firstname' => 'John',
              'lastname' => 'Doe'
            }
          ]
        })
        user = User.authenticate(29, 'deadbeef', 'cafebabe')
        assert_equal 29, user.user_id
      end
    end


    context 'string userid' do
      should 'return user' do
        Withings::Connection.stubs(:get_request).with('/user', anything(), anything(), anything()).returns({
          'users' => [
            {
              'id' => 29,
              'firstname' => 'John',
              'lastname' => 'Doe'
            }
          ]
        })
        begin
          user = User.authenticate('29', 'deadbeef', 'cafebabe')
          assert_equal 29, user.user_id
        rescue
          fail "should not raise"
        end
      end
    end

  end
end
