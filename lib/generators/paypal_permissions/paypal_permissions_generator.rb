module PaypalPermissions
  module Generators
    class PaypalPermissionsGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a paypal_permissions resource with NAME along with a database migration."

      hook_for :orm

      def generate_controller
        generate "controller", plural_name if behavior == :invoke
      end

      class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true

      def insert_paypal_permissions_routes
        if options.routes?
          route "match '#{plural_name}/request_permissions_callback' => '#{plural_name}#request_permissions_callback', :via => [ :post ], :as => :#{plural_name}_request_permissions_callback_url"
          route "resources :#{plural_name}"
        end
      end
    end
  end
end
