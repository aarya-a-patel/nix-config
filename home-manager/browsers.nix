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
      extensions.packages = firefox-extensions;
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
