{
  description = "Personal tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.buildEnv {
        name = "my-tools";

        paths = with pkgs; [
          bat
          chezmoi
          difftastic
          eza
          fzf
          gh
          git
          hyperfine
          jujutsu
          melody
          mise
          nodejs
          pnpm
          ruff
          tmux
          uv
          wget
          zed-editor
          zinit
        ];
      };
    };
}
