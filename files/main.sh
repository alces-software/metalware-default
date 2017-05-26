
echo "Running main.sh on <%= alces.nodename %> at $(date)!"

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
