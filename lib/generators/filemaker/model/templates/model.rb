<% module_namespacing do -%>
class <%= class_name %>
  include Filemaker::Model

  database '<%= db %>'
  layout '<%= lay %>'

<% @fields.map do |name, type| -%>
  <%= @type_mappings[type] %> :<%= name.parameterize.underscore %>, fm_name: '<%= name %>'
<% end -%>
end
<% end %>