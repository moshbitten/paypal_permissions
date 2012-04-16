require 'rails/generators/active_record'
require 'generators/paypal_permissions/orm_helpers'

module ActiveRecord
  module Generators
    class PaypalPermissionsGenerator < ActiveRecord::Generators::Base
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      include PaypalPermissions::Generators::OrmHelpers
      source_root File.expand_path("../templates", __FILE__)

      def copy_paypal_permissions_migration
        if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
          migration_template "migration_existing.rb", "db/migrate/add_paypal_permissions_to_#{table_name}"
        else
          migration_template "migration.rb", "db/migrate/paypal_permissions_create_#{table_name}"
        end
      end

      def generate_paypal_permissions_model
        invoke "active_record:model", [ name ], :migration => false unless model_exists? && behavior == :invoke
      end

      def inject_paypal_permissions_content
        inject_into_class(model_path, class_name, model_contents + <<ACCESSIBLE_FIELDS) if model_exists?
  attr_accessible :ppp_access_token, :ppp_access_token_verifier
ACCESSIBLE_FIELDS
      end

      def migration_data
<<MIGRATION_FIELDS
      # GetAccessToken response fields
      t.string :ppp_access_token
      t.string :ppp_access_token_verifier
MIGRATION_FIELDS
      end

      def indexes
<<INDEXES
INDEXES
      end
    end
  end
end
