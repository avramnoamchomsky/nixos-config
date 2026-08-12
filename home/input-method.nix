{ ... }:

{
  # Keep the selected Fcitx group and input-method order reproducible.
  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      # Group Name
      Name=Default
      # Layout
      Default Layout=us
      # Default Input Method
      DefaultIM=rime

      [Groups/0/Items/0]
      # Name
      Name=keyboard-us
      # Layout
      Layout=

      [Groups/0/Items/1]
      # Name
      Name=rime
      # Layout
      Layout=

      [GroupOrder]
      0=Default
    '';
  };

  xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
    force = true;
    text = ''
      patch:
        __include: rime_ice_suggestion:/

        schema_list:
          - schema: double_pinyin_flypy
    '';
  };
}
