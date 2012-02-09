module PaypalPermissions
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a PaypalPermissions initializer and copies locale files to your application."
      class_option :orm

      def update_configuration
        dev_test_config = <<-DEV_TEST_CONFIG
#{Rails.application.class.name.split('::').first}::Application.configure do
  config.after_initialize do
    permissions_options = {
      :login => "TODO: your PayPal sandbox caller login",
      :password => "TODO: your PayPal sandbox caller login",
      :signature => "TODO: your PayPal sandbox caller login",
      :app_id => "APP-80W284485P519543T",  # This is the app_id for all PayPal Permissions Service sandbox test apps
    }
    ::PAYPAL_PERMISSIONS_GATEWAY = ActiveMerchant::Billing::PaypalPermissionsGateway.new(permissions_options)
  end
end
        DEV_TEST_CONFIG

        prod_config = <<-PROD_CONFIG
#{Rails.application.class.name.split('::').first}::Application.configure do
  config.after_initialize do
    permissions_options = {
      :login => "TODO: your PayPal live caller login",
      :password => "TODO: your PayPal live caller login",
      :signature => "TODO: your PayPal live caller login",
      :app_id => "TODO: your PayPal live app id",
    }
    ::PAYPAL_PERMISSIONS_GATEWAY = ActiveMerchant::Billing::PaypalPermissionsGateway.new(permissions_options)
  end
end
        PROD_CONFIG

        application(nil, :env => "development") do
          dev_test_config
        end

        application(nil, :env => "test") do
          dev_test_config
        end

        application(nil, :env => "production") do
          prod_config
        end
      end

      def copy_initializer
        template "paypal_permissions.rb", "config/initializers/paypal_permissions.rb"
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/paypal_permissions.en.yml"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
