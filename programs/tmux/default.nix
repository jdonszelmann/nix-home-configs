{ pkgs, ... }: {
  programs.tmux =
    {
      enable = true;
      mouse = true;
      clock24 = true;

      shortcut = "k";


      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.mkTmuxPlugin {
            pluginName = "suspend";
            version = "1a2f806";
            src = pkgs.fetchFromGitHub {
              owner = "MunifTanjim";
              repo = "tmux-suspend";
              rev = "1a2f806666e0bfed37535372279fa00d27d50d14";
              sha256 = "0j7vjrwc7gniwkv1076q3wc8ccwj42zph5wdmsm9ibz6029wlmzv";
            };
          };
          extraConfig = ''
            set -g @suspend_key 'F11'
          '';
        }
        {
          plugin = tmuxPlugins.mode-indicator;
        }
      ];

      extraConfig = ''
        # unbind every single normal keybinding
        unbind-key -a

        set -g set-titles on
        set -s escape-time 0

        set-option -g default-shell /bin/zsh

        set-window-option -g mode-keys vi

        # clipboard stuff
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
        bind v copy-mode
        bind p paste-buffer -p
        set -s set-clipboard on

        # get back normal terminal emulator bindings
        bind-key -n S-PPage copy-mode -u
        bind-key -T copy-mode -n S-NPage send-keys -X page-down

        # don't scroll to end when copying with mouse
        bind-key -T copy-mode    MouseDragEnd1Pane send-keys -X copy-pipe
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe
        bind-key -T copy-mode    DoubleClick1Pane  select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe
        bind-key -T copy-mode    TripleClick1Pane  select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe
        bind-key -T copy-mode-vi DoubleClick1Pane  select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe
        bind-key -T copy-mode-vi TripleClick1Pane  select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe

        #  window control
        bind t new-window -c "#{pane_current_path}"
        bind-key Tab next-window
        bind-key BTab previous-window
        set -g automatic-rename-format "#{?#{==:#{pane_current_path},$HOME},~,#{b:pane_current_path}} (#{pane_current_command})"
        set -g renumber-windows on
        bind-key Q confirm-before -p "kill-window #W? (y/n)" kill-window
        bind A last-window

        bind-key 1 select-window -t :0
        bind-key 2 select-window -t :1
        bind-key 3 select-window -t :2
        bind-key 4 select-window -t :3
        bind-key 5 select-window -t :4
        bind-key 6 select-window -t :5
        bind-key 7 select-window -t :6
        bind-key 8 select-window -t :7
        bind-key 9 select-window -t :8
        bind-key 0 select-window -t :9

        # pane control
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind L split-window -h -c "#{pane_current_path}"
        bind J split-window -v -c "#{pane_current_path}"
        bind H split-window -h -b -c "#{pane_current_path}"
        bind K split-window -v -b -c "#{pane_current_path}"
        bind x swap-pane -D
        bind -r a select-pane -l
        bind-key q confirm-before -p "kill-pane #P? (y/n)" kill-pane

        bind-key o choose-tree -wZ
        bind-key O choose-tree -sZ

        # get back command mode and some other basics...
        bind : command-prompt
        bind r source-file ~/.config/tmux/tmux.conf \; display "config reloaded"
        bind-key ? list-keys

        # Scroll oin man etc
        tmux_commands_with_legacy_scroll="nano less more man git"

        bind-key -T root WheelUpPane \
            if-shell -Ft= '#{?mouse_any_flag,1,#{pane_in_mode}}' \
                'send -Mt=' \
                'if-shell -t= "#{?alternate_on,true,false} || echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
                    "send -t= Up" "copy-mode -et="'

        bind-key -T root WheelDownPane \
            if-shell -Ft = '#{?pane_in_mode,1,#{mouse_any_flag}}' \
                'send -Mt=' \
                'if-shell -t= "#{?alternate_on,true,false} || echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
                    "send -t= Down" "send -Mt="'

         # bind -n DoubleClick1Pane run-shell "${pkgs.xdragon}/bin/dragon -x '#{pane_current_path}/#{mouse_word}'"
      '';
    };
}
