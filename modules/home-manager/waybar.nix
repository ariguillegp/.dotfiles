{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = builtins.readFile ./waybar.css;
    settings = [{
      layer = "top";
      position = "top";
      mod = "dock";
      exclusive = true;
      passtrough = false;
      gtk-layer-shell = true;
      height = 0;
      modules-left = [
        "hyprland/workspaces"
        "custom/divider"
        "cpu"
        "custom/divider"
        "memory"
      ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "network"
        "custom/divider"
        "backlight"
        "custom/divider"
        "pulseaudio"
        "custom/divider"
        "battery"
        "custom/divider"
        "clock"
      ];
      "hyprland/window" = { format = "{}"; };
      "wlr/workspaces" = {
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
        all-outputs = true;
        on-click = "activate";
      };
      battery = { format = "󰁹 {}%"; };
      cpu = {
        interval = 10;
        format = "  {}%";
        max-length = 10;
        on-click = "";
      };
      memory = {
        interval = 30;
        format = "   {}%";
        format-alt = "  {used:0.1f}G";
        max-length = 10;
      };
      backlight = {
        format = "󰖨  {}";
        device = "acpi_video0";
      };
      network = {
        format = "󰖩  {essid}";
        format-disconnected = "󰖪  disconnected";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 {volume}%";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
          headphone = "󰋋";
          hands-free = "󰏳";
          headset = "󰋎";
          phone = "";
          portable = "";
          car = "";
        };
        scroll-step = 5;
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
        tooltip-format = "{desc}";
      };
      clock = {
        format = "  {:%I:%M %p    %m/%d} ";
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
      };
      "custom/divider" = {
        format = " | ";
        interval = "once";
        tooltip = false;
      };
      "custom/endright" = {
        format = "";
        interval = "once";
        tooltip = false;
      };
    }];
  };
}
