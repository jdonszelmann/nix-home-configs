{pkgs, config, ...}: {
    # sudo groupadd uinput
    # sudo usermod -aG input $USER
    # sudo usermod -aG uinput $USER
    # echo "KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"" >> /etc/udev/rules.d/99-input.rules 
    # reboot or sudo udevadm control --reload-rules && sudo udevadm trigger
    # sudo modprobe uinput
    systemd.user.services.kanata ={
        Unit = {
            Description = "kanata";
        };

        Service = {
            Restart = "always";
            RestartSec = "3";
            ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${config.home.file.kanata.target}";
            Nice = "-20";
        };

        Install = {
            WantedBy = ["default.target"];
        };
    };


    home.file.kanata = {
        target = ".config/kanata/kanata.kbd";
        text = builtins.readFile ./cfg.kbd;
    };
}
