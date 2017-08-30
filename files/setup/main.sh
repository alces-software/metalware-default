echo "Running main.sh on <%= alces.nodename %> at $(date)!"


export CORE_DIR=/var/lib/metalware/rendered/self/
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

echo 'Running platform setup scripts:'
for script in $CORE_DIR/platform ; do
    bash $script
done

echo 'Running user setup scripts:'
for script in $CORE_DIR/setup ; do
    bash $script
done

echo 'Running core setup scripts:'
run_script base
run_script networking

echo 'Running user scripts:'
for script in $CORE_DIR/scripts ; do
    bash $script
done