
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

<% node.plugins.each do |plugin| %>
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

<% node.plugins.each do |plugin| %>
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
