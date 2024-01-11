# Fixes problem of super-<num> stopping working for gnome shortcuts
#
# From https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/1250#note_718536

for i in {1..9}; do
  gsettings set "org.gnome.shell.keybindings" "switch-to-application-$i" "[]"
done
