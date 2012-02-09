class PaypalPermissionsCreate<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    create_table(:<%= table_name %>) do |t|
<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>

<%= migration_data -%>

      t.timestamps
    end

<%= indexes -%>
  end
end
