{
  lib,
  python3,
  python3Packages,
  nodejs,
  chromium,
  makeWrapper,
}: let
  python-jobspy = python3Packages.buildPythonPackage rec {
    pname = "python-jobspy";
    version = "1.1.82";
    pyproject = true;

    src = python3Packages.fetchPypi {
      pname = "python_jobspy";
      inherit version;
      hash = "sha256-Mu+0htpetg3FSldLtKH7ZoOP3udWmaemAarnY2N9yOo=";
    };

    build-system = with python3Packages; [
      poetry-core
    ];

    dependencies = with python3Packages; [
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
  python3Packages.buildPythonApplication rec {
    pname = "applypilot";
    version = "0.3.0";
    pyproject = true;

    src = python3Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-KsTaZoHtD8jGM/VMNWXdL6JRA5lLDbNBhwDSqHlaVQ4=";
    };

    build-system = with python3Packages; [
      hatchling
    ];

    nativeBuildInputs = [
      makeWrapper
    ];

    dependencies = with python3Packages; [
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
        --set-default CHROME_PATH ${lib.getExe chromium}
    '';

    meta = with lib; {
      description = "AI-powered end-to-end job application pipeline";
      homepage = "https://github.com/Pickle-Pixel/ApplyPilot";
      license = licenses.agpl3Only;
      mainProgram = "applypilot";
      platforms = platforms.linux;
    };
  }
