module PaypalPermissions
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a PaypalPermissions initializer."
      class_option :orm

      def update_configuration
        dev_test_config = <<-DEV_TEST_CONFIG
#{Rails.application.class.name.split('::').first}::Application.configure do
  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
    permissions_options = {
      :login => 'TODO: your PayPal sandbox caller login',
      :password => 'TODO: your PayPal sandbox caller password',
      :signature => 'TODO: your PayPal sandbox caller signature',
      :app_id => 'APP-80W284485P519543T',  # This is the app_id for all PayPal Permissions Service sandbox test apps
    }
    ::PAYPAL_PERMISSIONS_GATEWAY = ActiveMerchant::Billing::PaypalPermissionsGateway.new(permissions_options)
  end
end
        DEV_TEST_CONFIG

        prod_config = <<-PROD_CONFIG
#{Rails.application.class.name.split('::').first}::Application.configure do
  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :production
    permissions_options = {
      :login => 'TODO: your PayPal live caller login',
      :password => 'TODO: your PayPal live caller password',
      :signature => 'TODO: your PayPal live caller signature',
      :app_id => 'TODO: your PayPal live app id',
    }
    ::PAYPAL_PERMISSIONS_GATEWAY = ActiveMerchant::Billing::PaypalPermissionsGateway.new(permissions_options)
  end
end
        PROD_CONFIG

        # Don't use... "application(nil, :env => "development") do" here.
        # Somewhere along the line, in the case where the :env parameter is supplied,
        # railties went from using append_file to using inject_into_file after an env_file_sentinel,
        # which changes the semantics drastically.
        #
        append_file("config/environments/development.rb") do
          "\n#{dev_test_config}"
        end

        append_file("config/environments/test.rb") do
          "\n#{dev_test_config}"
        end

        append_file("config/environments/production.rb") do
          "\n#{prod_config}"
        end
      end

      def copy_initializer
        # Nothing in the initializer yet, but once there is, just uncomment the following.
        template "paypal_permissions.rb", "config/initializers/paypal_permissions.rb"
      end

      def copy_locale
        # Nothing in the locales file yet, but once there is, just uncomment the following.
        # copy_file "../../../config/locales/en.yml", "config/locales/paypal_permissions.en.yml"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
