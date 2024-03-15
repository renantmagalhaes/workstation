show_my_ip() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_network_icon" '󰩠')"
  local color="$(get_tmux_option "@catppuccin_network_color" "$thm_cyan")"
  
  # Call the network-my_ip.sh script and store its output
  local my_ip="$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com |sed -e "s/\"//g")"
  
  # Here we combine the date with the network my_ip output
  local text="$my_ip"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}