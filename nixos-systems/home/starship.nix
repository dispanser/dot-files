{
  programs.starship = {
    enable = true;
    settings = {
      aws.disabled    = true;
      gcloud.disabled = true;
      time.disabled   = false;
      cmake.disabled  = true;
      character = {
        success_symbol = "[╰─▶](bold green)";
        error_symbol = "[╰─✗](bold red)";
      };
      directory = {
        repo_root_style = "bold blue";
        truncation_symbol = "…/";
      };
      right_format = "$time$battery";
    };
  };
}

