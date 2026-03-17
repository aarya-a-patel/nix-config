{
  pkgs,
  lib,
  ...
}: let
  firefox-extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    bitwarden
    darkreader
    onetab
    one-click-wayback
    indie-wiki-buddy
  ];
in {
  programs.firefox = {
    enable = true;
    profiles.default.extensions.packages = firefox-extensions;
  };
  programs.zen-browser = {
    enable = true;
    profiles.default = {
      settings = {
        "browser.tabs.allow_transparent_browser" = true;
        "zen.widget.linux.transparency" = true;
        "zen.view.compact.should-enable-at-startup" = true;
        "zen.theme.gradient.show-custom-colors" = true;
        "zen.view.grey-out-inactive-windows" = false;
      };
      extensions.packages =
        firefox-extensions
        ++ (with pkgs.nur.repos.rycee.firefox-addons; [
          transparent-zen
          # zen-internet
        ]);
      mods = [
        "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
        "a5f6a231-e3c8-4ce8-8a8e-3e93efd6adec" # Cleaned URL Bar
      ];
    };
    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
  };

  stylix.targets.firefox.profileNames = ["default"];
  stylix.targets.zen-browser.enable = false;

  # Set default browser
  xdg.mimeApps = {
    enable = lib.mkDefault true;

    defaultApplications = let
      browser = "zen-beta.desktop";
    in {
      "text/html" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
    };
  };
}
