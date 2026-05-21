{ config, lib, pkgs, vars, ... }: {
    # boot.automount is based on LoaderDevicePartUUID that are given from bootloader. Systemd-boot gives this variable, but some unknown bootloader (maybe even GRUB2) doesn't give it. I hate this. This service mounts /boot only from UEFI variables
    boot.initrd.systemd = {
        enable = true;
        initrdBin = with pkgs; [
            coreutils
            util-linux
        ];
        services.smart-boot-mount = {
            description = "ESP mount based on UEFI BootCurrent/Boot000X variables only";
            # We need successful end of root (/sysroot) mount
            requires = [ "initrd-root-fs.target" ];
            after    = [ "initrd-root-fs.target" ];

            before   = [ "initrd-fs.target" ]; # Before all the root dirs mount target
            wantedBy = [ "initrd-fs.target" ];

            unitConfig.DefaultDependencies = false; # At initrd only

            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
            };

            script = ''
                # Fast exit if we are booting not in the UEFI-mode or /boot is already mounted or I have no access to /dev/disk/by-partuuid
                mkdir -p /sysroot/${config.boot.loader.efi.efiSysMountPoint}
                [ "$(ls -A \"/sysroot/boot\" 2>/dev/null)" ] && exit -1
                [ -d "/sys/firmware/efi/efivars" ] && [ "$(ls -A \"/sys/firmware/efi/efivars\" 2>/dev/null)" ] || exit 1

                BOOT_HEX=$(od -An -t x1 -j 4 -N 2 /sys/firmware/efi/efivars/BootCurrent-8be4df61-93ca-11d2-aa0d-00e098032b8c | tr -d ' \n')
                [ -z "$BOOT_HEX" ] && exit 2

                BOOT_NUM="''${BOOT_HEX:2:2}''${BOOT_HEX:0:2}" # Little Endian fixing

                BOOT_VAR="/sys/firmware/efi/efivars/Boot''${BOOT_NUM}-8be4df61-93ca-11d2-aa0d-00e098032b8c"
                VAR_HEX=$(od -An -v -t x1 "$BOOT_VAR" 2>/dev/null | tr -d ' \n')

                PART_OFFSET_STR=''${VAR_HEX#*04012a00}
                [ "$PART_OFFSET_STR" == "$VAR_HEX" ] && exit 3

                RAW_UUID=''${PART_OFFSET_STR:40:32}
                echo "RAW_UUID: $RAW_UUID"
                [ ''${#RAW_UUID} -ne 32 ] && exit 4

                # Little Endian fixing
                ESP_UUID="''${RAW_UUID:6:2}''${RAW_UUID:4:2}''${RAW_UUID:2:2}''${RAW_UUID:0:2}-''${RAW_UUID:10:2}''${RAW_UUID:8:2}-''${RAW_UUID:14:2}''${RAW_UUID:12:2}-''${RAW_UUID:16:4}-''${RAW_UUID:20:12}"
                echo "ESP_UUID: $ESP_UUID"

                mount PARTUUID="$ESP_UUID" /sysroot/${config.boot.loader.efi.efiSysMountPoint} || exit 5
                exit 0
            '';
        };
    };
}
