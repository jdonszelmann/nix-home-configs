{pkgs, inputs, ...}: {
    programs.kitty = {
        enable = true;
        font.name = "Jetbrains Mono";
        font.size = 13.0;
        font.package = pkgs.jetbrains-mono;

        settings = {
            scrollback_lines = 20000;

            repaint_delay = 10;
            input_delay = 3;

            enable_audio_bell = false;
            update_check_interval = 0;

            initial_window_width = "95c";
            initial_window_height = "30c";
            remember_window_size = "no";

            draw_minimal_borders = false;
            hide_window_decorations = true;

            shell = "${pkgs.tmux}/bin/tmux";
            clipboard_control = "write-clipboard write-primary read-clipboard read-primary";

            foreground = "#fcfcfc";
            background = "#232627";
            linux_display_server = "auto";
        };

        keybindings = {
            "ctrl+f" = "launch --location=hsplit --allow-remote-control kitty +kitten ${inputs.kitty-search}/search.py @active-kitty-window-id";
            "ctrl+alt+r" = "load_config_file";
            "ctrl+shift+r" = "no_op";
            "ctrl+EQUAL" = "change_font_size all +2.0";
            "ctrl+minus" = "change_font_size all -2.0";
            "ctrl+0" = "change_font_size all 0";
            "ctrl+/" = "send_text all \x1b[47;5u";
        };
    };
}
