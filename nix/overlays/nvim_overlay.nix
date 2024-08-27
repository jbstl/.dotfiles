{config, pkgs, lib, ...}:

{
  nixpkgs.overlays = [

    (self: super: {
      neovim = super.neovim.override {
        version = "0.10.0";
      };
    })

    # (final: prev: {
    #     neovim = prev.neovim.overrideAttrs (prevAttrs: {
    #       src = pkgs.fetchFromGitHub {
    #         owner = "neovim";
    #         repo = "neovim";
    #         rev = "27fb62988e922c2739035f477f93cc052a4fee1e";
    #         hash = "sha256-FCOipXHkAbkuFw9JjEpOIJ8BkyMkjkI0Dp+SzZ4yZlw=";
    #       };
    #     });
    # })
  ];
}
