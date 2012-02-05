module ActiveMerchant::Billing #::PaypalPermissions
  module Generators
    class InstallGenerator < Rails::Generators::Base
      namespace "paypal_permissions"
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a Devise initializer and copies locale files to your application."
      class_option :orm

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
