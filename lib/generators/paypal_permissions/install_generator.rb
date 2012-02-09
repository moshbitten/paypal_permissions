module PaypalPermissions
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a PaypalPermissions initializer and copies locale files to your application."
      class_option :orm

      def update_configuration
        application(nil, :env => "development") do <<AFTER_INITIALIZE
#{Rails.application.class.name.split('::').first}::Application.configure do
  config.after_initialize do
    permissions_options = {
      :login => "TODO: your PayPal caller login",
      :password => "TODO: your PayPal caller login",
      :signature => "TODO: your PayPal caller login",
      :app_id => "APP-80W284485P519543T",  # This is the app_id for all PayPal Permissions Service sandbox test apps
    }
    ::PAYPAL_PERMISSIONS_GATEWAY = ActiveMerchant::Billing::PaypalPermissionsGateway.new(permissions_options)
  end
end
AFTER_INITIALIZE
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
