module PaypalPermissions
  module Generators
    class ResourcesGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a paypal_permissions resource along with a database migration."

      # hook_for :orm

      class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true

      def add_paypal_permissions_routes
        route "resources :paypal_permissions"
      end
    end
  end
end
