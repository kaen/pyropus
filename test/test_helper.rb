ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'authorization'

class ActiveSupport::TestCase

  module PermissionsTestHelpers
    # set the parameters to be passed in access tests
    def permission_test_params params = nil
      @permission_test_params = params unless params === nil
      @permission_test_params
    end

    # method is a HTTP method
    # action is a controller method
    # user can be a fixture or nil to log out
    def try_as method, action, user
        log_in user
        self.send(method, action, permission_test_params)
    end

    def succeed_as method, action, user
      try_as method, action, user
      assert [200, 302].include? response.response_code
    end

    def fail_as method, action, user
      try_as method, action, user
      assert_response 403
    end
  end

  module PermissionsDsl
    RESOURCE_MAP = { new: :get,
                     index: :get,
                     show: :get,
                     edit: :get,
                     create: :post,
                     update: :put,
                     destroy: :delete }

    # return an http method corresponding to an action name
    def self.action_to_method action
      return RESOURCE_MAP.include?(action) ? RESOURCE_MAP[action] : nil
    end

    # iterate through an array of actions and run the proc
    def self.get_actions args
      for arg in args
        case arg
        when Symbol
          action = arg
          method = PermissionsDsl.action_to_method(action) || :get
        when Hash
          action = arg[:action] || :index
          method = arg[:method] || :get
        else
          raise Exception, "Arg #{arg} of unexpected type #{arg.class}"
        end

        yield method, action

      end
    end

    def admin_action *args
      PermissionsDsl.get_actions(args) do |method, action|
        test "#{action.to_s} is inaccessible to unauthenticated users" do
          fail_as method, action, nil
          fail_as method, action ,users(:nobody)
        end

        test "#{action.to_s} is inaccessible to normal users" do
          fail_as method, action ,users(:normal)
        end

        test "#{action.to_s} is accessible to admins" do
          succeed_as method, action ,users(:admin)
        end
      end
    end

    def authenticated_action *args
      PermissionsDsl.get_actions(args) do |method, action|
        test "#{action.to_s} is inaccessible to unauthenticated users" do
          fail_as method, action, nil
          fail_as method, action ,users(:nobody)
        end

        test "#{action.to_s} is accessible to normal users" do
          succeed_as method, action ,users(:normal)
        end

        test "#{action.to_s} is accessible to admins" do
          succeed_as method, action ,users(:admin)
        end
      end
    end

    def public_action *args
      PermissionsDsl.get_actions(args) do |method, action|
        test "#{action.to_s} is accessible to unauthenticated users" do
          succeed_as method, action, nil
          succeed_as method, action ,users(:nobody)
        end

        test "#{action.to_s} is accessible to normal users" do
          succeed_as method, action ,users(:normal)
        end

        test "#{action.to_s} is accessible to admins" do
          succeed_as method, action ,users(:admin)
        end
      end
    end
  end

  include PermissionsTestHelpers
  extend PermissionsDsl


  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

end
