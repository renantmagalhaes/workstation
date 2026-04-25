{ config, pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "kvantum";
  };
}
