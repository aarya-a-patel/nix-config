{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
in {
  config.flake.modules = {
    homeManager.shell-core = {
      config,
      lib,
      pkgs,
      ...
    }: {
      programs.zsh = {
        enable = lib.mkDefault true;
        dotDir = lib.mkDefault "${config.xdg.configHome}/zsh";
        history = lib.mkDefault {
          path = "${config.xdg.dataHome}/zsh/history";
          extended = true;
          share = false;
          ignoreAllDups = true;
        };
        syntaxHighlighting.enable = lib.mkDefault true;
        initContent = lib.mkOrder 1500 ''
          ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
            zhm_history_prev
            zhm_history_next
            zhm_prompt_accept
            zhm_accept
            zhm_accept_or_insert_newline
          )
          ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(
            zhm_move_right
            zhm_clear_selection_move_right
          )
          ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(
            zhm_move_next_word_start
            zhm_move_next_word_end
          )

          bindkey -M hxins '^R' atuin-search
        '';
        autosuggestion = {
          enable = lib.mkDefault true;
          strategy = lib.mkDefault [
            "history"
            "completion"
          ];
        };
        plugins = [
          {
            name = "zsh-helix-mode";
            src = inputs.zsh-helix-mode.packages.${pkgs.stdenv.hostPlatform.system}.zsh-helix-mode;
            file = "share/zsh-helix-mode/zsh-helix-mode.plugin.zsh";
          }
        ];
      };

      programs.bash.enable = lib.mkDefault true;

      programs.atuin = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault true;
        enableZshIntegration = lib.mkDefault true;
      };

      programs.starship = {
        enable = lib.mkDefault true;
        enableTransience = lib.mkDefault true;
        enableZshIntegration = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault true;
      };
    };

    nixos.shell-core = {
      lib,
      pkgs,
      ...
    }: {
      programs.zsh = {
        enable = lib.mkDefault true;
        syntaxHighlighting.enable = lib.mkDefault true;
        autosuggestions = {
          enable = lib.mkDefault true;
          async = lib.mkDefault true;
        };
      };
      users.defaultUserShell = lib.mkOverride 900 pkgs.zsh;

      programs.starship = {
        enable = lib.mkDefault true;
        interactiveOnly = lib.mkDefault true;
      };
    };
  };
}
