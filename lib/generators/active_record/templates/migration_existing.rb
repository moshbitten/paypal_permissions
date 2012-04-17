class AddPaypalPermissionsTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.change
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
end
