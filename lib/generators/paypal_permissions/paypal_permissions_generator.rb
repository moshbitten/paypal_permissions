module PaypalPermissions
  module Generators
    class PaypalPermissionsGenerator < Rails::Generators::NamedBase
      namespace "paypal_permissions"
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a paypal_permissions resource with NAME along with a database migration."

      hook_for :orm

      class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true

      def insert_paypal_permissions_routes
        route "resources :#{plural_name}" if options.routes?
      end
    end
  end
end
