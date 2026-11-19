{ ... }:

{
  # Keep MSIME as the only input method across logins and rebuilds.
  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      # Group Name
      Name=Default
      # Layout
      Default Layout=us
      # Default Input Method
      DefaultIM=msime

      [Groups/0/Items/0]
      # Name
      Name=msime
      # Layout
      Layout=

      [GroupOrder]
      0=Default
    '';
  };
}
