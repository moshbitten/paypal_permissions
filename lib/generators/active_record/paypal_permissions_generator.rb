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
  attr_accessible :request_permissions_ack, :request_permissions_correlation_id, :request_permissions_request_token,
                  :request_permissions_verifier, :request_permissions_envelope_timestamp,
                  :request_permissions_errors, :request_permissions_raw_response,
                  :request_permissions_callback_ack, :request_permissions_callback_correlation_id, :request_permissions_callback_request_token,
                  :request_permissions_callback_verifier, :request_permissions_callback_envelope_timestamp,
                  :request_permissions_callback_errors, :request_permissions_callback_raw_response,
                  :get_access_token_ack, :get_access_token_correlation_id,
                  :get_access_token_verifier, :get_access_token_envelope_timestamp,
                  :get_access_token_errors, :get_access_token_raw_response
ACCESSIBLE_FIELDS
      end

      def migration_data
<<MIGRATION_FIELDS
      # RequestPermissions response fields
      t.string :request_permissions_ack
      t.string :request_permissions_correlation_id
      t.string :request_permissions_request_token
      t.datetime :request_permissions_envelope_timestamp
      t.text :request_permissions_errors
      t.text :request_permissions_raw_response

      # RequestPermissions callback fields
      t.string :request_permissions_callback_ack
      t.string :request_permissions_callback_correlation_id
      t.string :request_permissions_callback_verifier
      t.datetime :request_permissions_callback_envelope_timestamp
      t.text :request_permissions_callback_errors
      t.text :request_permissions_callback_raw_response
      
      # GetAccessToken response fields
      t.string :get_access_token_ack
      t.string :get_access_token_correlation_id
      t.string :get_access_token_request_token
      t.string :get_access_token_verifier
      t.datetime :get_access_token_envelope_timestamp
      t.text :get_access_token_errors
      t.text :get_access_token_raw_response
MIGRATION_FIELDS
      end

      def indexes
<<INDEXES
    add_index :#{table_name}, :request_permissions_request_token
    add_index :#{table_name}, :get_access_token_request_token
INDEXES
      end
    end
  end
end
