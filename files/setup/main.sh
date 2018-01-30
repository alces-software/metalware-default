echo "Running main.sh on <%= node.name %> at $(date)!"


export CORE_DIR=/var/lib/metalware/rendered/local/files/repo/core/
#mkdir -p "$CORE_DIR"

run_script() {
  bash "$CORE_DIR/$1.sh"
}
export -f run_script

install_file() {
  cp "$CORE_DIR/$1" "$2"
}
export -f install_file

echo

echo 'Setting root password'
usermod --password '<%= config.encrypted_root_password %>' root

echo 'Running platform setup scripts:'
if [ $(ls $CORE_DIR/../platform |wc -l) != 0 ] ; then
  for script in $CORE_DIR/../platform/* ; do
    bash $script
  done
fi

echo 'Running user setup scripts:'
if [ $(ls $CORE_DIR/../setup |wc -l) != 0 ] ; then
  for script in $CORE_DIR/../setup/* ; do
    bash $script
  done
fi

echo 'Running plugin setup scripts'
for plugin in $CORE_DIR/../../plugin/* ; do
  echo "Running setup scripts for $plugin"
  if [ $(ls $plugin/setup |wc -l) != 0 ] ; then
    for script in $plugin/setup/* ; do
        bash $script
    done
  fi
done

echo 'Running core setup scripts:'
run_script base
run_script networking

echo 'Running user scripts:'
if [ $(ls $CORE_DIR/../scripts |wc -l) != 0 ] ; then
  for script in $CORE_DIR/../scripts/* ; do
    bash $script
  done
fi

echo 'Running plugin scripts'
for plugin in $CORE_DIR/../../plugin/* ; do
  echo "Running scripts for $plugin"
  if [ $(ls $plugin/scripts |wc -l) != 0 ] ; then
    for script in $plugin/scripts/* ; do
        bash $script
    done
  fi
done
