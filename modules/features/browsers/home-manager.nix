{config, ...}: let
  module = {
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
    chromium-extensions = [
      {
        # Bitwarden
        id = "nngceckbapebfimnlniiiahkandclblb";
        hash = "sha256-XOVs2Tvay8hQ13SHz+728BDu2mMyQ0JxUuUI6FZ1NaM=";
      }
      {
        # Dark Reader
        id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
        hash = "sha256-jAhpgyVucHif6fJ2VUJoOtPAcHUh7BdAEMr9JpdocBY=";
      }
      {
        # OneTab
        id = "chphlpgkkbolifaimnlloiipkdnihall";
        hash = "sha256-LkQLIahNewg6u+1AM85s0Ln0XsPNdfyVgGS0YqTkPBc=";
      }
      {
        # Indie Wiki Buddy
        id = "fkagelmloambgokoeokbpihmgpkbgbfm";
        hash = "sha256-VGrVknMv49rPxFlJhxf8w0+ESjItiP8wlCC9vp69Pow=";
      }
      {
        # Internet Archive Wayback Machine, the Chromium equivalent of one-click-wayback.
        id = "fpnmgdkabkmnadcjpehmlllkndpkmiak";
        hash = "sha256-ImwsfOg+FHbRARXFMJoGej5M3uRbXThyZZDms98b798=";
      }
    ];
  in {
    programs.chromium.enable = true;
    programs.firefox = {
      enable = true;
      profiles.default.extensions.packages = firefox-extensions;
    };
    programs.helium = {
      enable = true;
      extensions = chromium-extensions;
      preferences.helium.browser.layout = 2;
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
          ]);
        mods = [
          "906c6915-5677-48ff-9bfc-096a02a72379"
          "a5f6a231-e3c8-4ce8-8a8e-3e93efd6adec"
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

    xdg.mimeApps = {
      enable = lib.mkDefault true;
      defaultApplications = let
        browser = "zen-beta.desktop";
      in {
        "text/html" = browser;
        "application/pdf" = "org.pwmt.zathura.desktop";
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
      };
    };
  };
in {
  config.flake.modules.homeManager.browsers = module;
}
