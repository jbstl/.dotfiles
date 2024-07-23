self: super:
let
  unstable = import <nixos-unstable> {};
in
{
  neovim = unstable.neovim;
}
