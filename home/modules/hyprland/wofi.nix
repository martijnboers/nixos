{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 750;
      height = 400;
      always_parse_args = true;
      show_all = false;
      print_command = true;
      insensitive = true;
      prompt = "Search";
    };
    style = builtins.readFile ../../assets/css/wofi.css;
  };
}
