
echo "Running main.sh on <%= alces.nodename %> at $(date)!"


core=/tmp/metalware/core
mkdir -p "$core"

run_script() {
  bash "$core/$1.sh"
}

install_file() {
  cp "$core/$1" "$2"
}


echo
echo 'Requesting core setup files'
<% alces.files.core.each do |file| %>
  <% if file.error %>
echo '<%= file.name %>: <%= file.error %>'
  <% else %>
curl "<%= file.url %>" > "$core/<%= file.name %>"
  <% end %>
<% end %>


echo 'Running Alces core setup'
run_script base
run_script networking


# Below are examples for how users could make use of `files` feature.

echo
echo 'Running scripts:'
<% alces.files.scripts.each do |script| %>
  <% if script.error %>
echo '<%= script.name %>: <%= script.error %>'
  <% else %>
curl "<%= script.url %>" | /bin/bash
  <% end %>
<% end %>

mkdir -p /tmp/configs
echo
echo 'Requesting configs:'
<% alces.files.configs.each do |config| %>
  <% if config.error %>
echo '<%= config.name %>: <%= config.error %>'
  <% else %>
config_file=/tmp/configs/<%= config.name %>
curl "<%= config.url %>" > "$config_file"
echo "Config $config_file saved with contents:"
cat "$config_file"
  <% end %>
<% end %>

# XXX Request hosts and genders here too.
