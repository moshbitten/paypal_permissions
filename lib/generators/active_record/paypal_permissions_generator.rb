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

      def generate_model
        invoke "active_record:model", [name], :migration => false unless model_exists? && behavior == :invoke
      end

      def inject_paypal_permissions_content
        inject_into_class(model_path, class_name, model_contents + <<CONTENT) if model_exists?
  # Setup accessible (or protected) attributes for your model
  attr_accessible :ack, :correlation_id, :token, :envelope_timestamp, :errors, :raw_response
CONTENT
      end

      def migration_data
<<MIGRATION_FIELDS
      ## Paypal Permissions response fields
      t.string :ack
      t.string :correlation_id
      t.string :token
      t.datetime :envelope_timestamp
      t.text :errors
      t.text :raw_response
MIGRATION_FIELDS
      end
    end
  end
end
