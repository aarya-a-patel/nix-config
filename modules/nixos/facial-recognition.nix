{...}: {
  # Facial recongition
  services.howdy = {
    enable = true;
    control = "sufficient";
  };
  services.linux-enable-ir-emitter.enable = true;
}
