{config, ...}: let
  package = pkgs:
    pkgs.callPackage (
      {
        lib,
        python3Packages,
        nodejs,
        chromium,
        playwright-driver,
        makeWrapper,
        playwrightDriverBrowsers ? playwright-driver.browsers,
      }: let
        py = python3Packages;

        python-jobspy = py.buildPythonPackage rec {
          pname = "python-jobspy";
          version = "1.1.82";
          pyproject = true;

          src = py.fetchPypi {
            pname = "python_jobspy";
            inherit version;
            hash = "sha256-Mu+0htpetg3FSldLtKH7ZoOP3udWmaemAarnY2N9yOo=";
          };

          build-system = [py.poetry-core];

          dependencies = with py; [
            requests
            beautifulsoup4
            pandas
            numpy
            pydantic
            tls-client
            markdownify
            regex
          ];

          pythonRelaxDeps = [
            "numpy"
            "markdownify"
            "regex"
          ];

          pythonImportsCheck = ["jobspy"];
          doCheck = false;
        };
      in
        py.buildPythonApplication rec {
          pname = "applypilot";
          version = "0.3.0";
          pyproject = true;

          src = py.fetchPypi {
            inherit pname version;
            hash = "sha256-KsTaZoHtD8jGM/VMNWXdL6JRA5lLDbNBhwDSqHlaVQ4=";
          };

          build-system = [py.hatchling];

          nativeBuildInputs = [makeWrapper];

          dependencies = with py; [
            typer
            rich
            httpx
            beautifulsoup4
            playwright
            python-dotenv
            pyyaml
            pandas
            python-jobspy
          ];

          pythonImportsCheck = ["applypilot"];
          doCheck = false;

          postFixup = ''
            wrapProgram $out/bin/applypilot \
              --prefix PATH : ${lib.makeBinPath [nodejs chromium]} \
              --set-default CHROME_PATH ${lib.getExe chromium} \
              --set-default PLAYWRIGHT_BROWSERS_PATH ${playwrightDriverBrowsers} \
              --set-default PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS true
          '';

          meta = with lib; {
            description = "AI-powered end-to-end job application pipeline";
            homepage = "https://github.com/Pickle-Pixel/ApplyPilot";
            license = licenses.agpl3Only;
            mainProgram = "applypilot";
            platforms = platforms.linux;
          };
        }
    ) {};
in {
  config.repo.packageBuilders.apply-pilot = package;
}
