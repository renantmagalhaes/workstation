show_is_online() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_is_online_icon" 'Online')"
  local color="$(get_tmux_option "@catppuccin_is_online_color" "#bd93f9")"
  
  # Call the network-bandwidth.sh script and store its output
  local bandwidth="$(~/.tmux/plugins/tmux-online-status/scripts/online_status_icon.sh)"
  
  # Here we combine the date with the network bandwidth output
  local text="$bandwidth"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}