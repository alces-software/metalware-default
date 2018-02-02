
<%
# Sort plugins by `priority` config value, with plugins with a lower value for
# `priority` appearing first.  Plugins without `priority` set will default to a
# priority of 9999, i.e. will probably be last unless a plugin has a priority
# explicitly set to more than this.
default_priority = 9999
prioritized_plugins = node.plugins.sort_by do |plugin|
  plugin.config.priority || default_priority
end
%>

echo "Running main.sh on <%= node.name %> at $(date)!"


export CORE_DIR=/tmp/metalware/core
mkdir -p "$CORE_DIR"

run_script() {
  bash "$CORE_DIR/$1.sh"
}
export -f run_script

install_file() {
  cp "$CORE_DIR/$1" "$2"
}
export -f install_file


echo
echo 'Requesting core setup files'
<% node.files.core.each do |file| %>
  <% if file.error %>
echo '<%= file.name %>: <%= file.error %>'
  <% else %>
curl "<%= file.url %>" > "$CORE_DIR/<%= file.name %>"
  <% end %>
<% end %>

echo
echo 'Running platform setup scripts:'
<% node.files.platform.each do |script| %>
  <% if script.error %>
echo '<%= script.name %>: <%= script.error %>'
  <% else %>
curl "<%= script.url %>" | /bin/bash
  <% end %>
<% end %>

echo
echo 'Running user setup scripts:'
<% node.files.setup.each do |script| %>
  <% if script.error %>
echo '<%= script.name %>: <%= script.error %>'
  <% else %>
curl "<%= script.url %>" | /bin/bash
  <% end %>
<% end %>

<% prioritized_plugins.each do |plugin| %>
echo
echo 'Running setup scripts for plugin `<%= plugin.name %>`:'
  <% (plugin.files.setup || []).each do |script| %>
    <% if script.error %>
echo '<%= script.name %>: <%= script.error %>'
    <% else %>
curl "<%= script.url %>" | /bin/bash
    <% end %>
  <% end %>
<% end %>

echo 'Running Alces core setup'
run_script base
run_script networking


echo
echo 'Running user scripts:'
<% node.files.scripts.each do |script| %>
  <% if script.error %>
echo '<%= script.name %>: <%= script.error %>'
  <% else %>
curl "<%= script.url %>" | /bin/bash
  <% end %>
<% end %>

<% prioritized_plugins.each do |plugin| %>
echo 'Running scripts for plugin `<%= plugin.name %>`:'
  <% (plugin.files.scripts || []).each do |script| %>
    <% if script.error %>
echo '<%= script.name %>: <%= script.error %>'
    <% else %>
curl "<%= script.url %>" | /bin/bash
    <% end %>
  <% end %>
<% end %>

# XXX Request hosts and genders here too.
