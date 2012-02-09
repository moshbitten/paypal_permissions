class AddPaypalPermissionsTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    change_table(:<%= table_name %>) do |t|
<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>

<%= migration_data -%>

      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

<%= indexes -%>
  end

  def self.down
    # We won't make assumptions about how to roll back a migration to a previously existing model.
    # If you'd like to be able to roll back, remove the ActiveRecord::IrreversibleMigration line
    # and make your edits below.
    raise ActiveRecord::IrreversibleMigration
  end
end
