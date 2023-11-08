show_network() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_network_icon" '󰀂')"
  local color="$(get_tmux_option "@catppuccin_network_color" "#f8f8f2")"
  
  # Call the network-bandwidth.sh script and store its output
  local bandwidth="$(~/.tmux/plugins/tmux-network-bandwidth/scripts/network-bandwidth.sh)"
  
  # Here we combine the date with the network bandwidth output
  local text="$bandwidth"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}