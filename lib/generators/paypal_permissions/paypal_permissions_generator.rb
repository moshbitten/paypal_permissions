module ActiveMerchant::Billing::PaypalPermissions
  module Generators
    class PaypalPermissionsGenerator < Rails::Generators::NamedBase
      namespace "paypal_permissions"
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a resource with the given NAME along with a database migration."

      # hook_for :orm

      class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true

      def add_paypal_permissions_routes
        route "resources :#{plural_name}"
      end
    end
  end
end
