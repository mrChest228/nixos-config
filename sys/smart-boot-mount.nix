{ config, lib, pkgs, vars, ... }: {
    boot.initrd.systemd = {
        initrdBin = [
            coreutils
            util-linux
        ];
        services.smart-boot-mount = {
            description = "ESP mount based on UEFI BootCurrent/Boot000X variables only";
            requires = [ # We need successful end of these utils to start us
                "initrd-root-fs.target"          # After root (/sysroot) mount
                "systemd-udev-settle.service"    # After the /dev/*
                "sys-firmware-efi-efivars.mount" # After the efivars
            ];
            after = [
                "initrd-root-fs.target"
                "systemd-udev-settle.service"
                "sys-firmware-efi-efivars.mount"
            ];

            before   = [ "initrd-fs.target" ]; # Before all the root dirs mount target
            requiredBy = [ "initrd-fs.target" ];

            unitConfig.DefaultDependencies = false; # At initrd only

            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
            };

            script = ''
                # Fast exit if we are booting not in the UEFI-mode or /boot is already mounted
                [ -d "/sysroot/boot" ] || exit -1
                [ -d "/sys/firmware/efi/efivars" ] || exit 1

                BOOT_HEX=$(od -An -t x1 -j 4 -N 2 /sys/firmware/efi/efivars/BootCurrent-8be4df61-93ca-11d2-aa0d-00e098032b8c | tr -d ' \n')
                [ -z "$BOOT_HEX" ] && exit 2

                BOOT_NUM="''${BOOT_HEX:2:2}''${BOOT_HEX:0:2}" # Little Endian fixing

                BOOT_VAR="/sys/firmware/efi/efivars/Boot''${BOOT_NUM}-8be4df61-93ca-11d2-aa0d-00e098032b8c"
                VAR_HEX=$(od -An -v -t x1 "$BOOT_VAR" 2>/dev/null | tr -d ' \n')

                PART_OFFSET_STR=''${VAR_HEX#*04012a00}
                [ "$PART_OFFSET_STR" == "$VAR_HEX" ] && exit 3

                RAW_UUID=''${PART_OFFSET_STR:24:32}
                [ ''${#RAW_UUID} -n 32 ] && exit 4
                # Little Endian fixing
                TARGET_UUID="''${RAW_UUID:6:2}''${RAW_UUID:4:2}''${RAW_UUID:2:2}''${RAW_UUID:0:2}-''${RAW_UUID:10:2}''${RAW_UUID:8:2}-''${RAW_UUID:14:2}''${RAW_UUID:12:2}-''${RAW_UUID:16:4}-''${RAW_UUID:20:12}"

                DEV_PATH="/dev/disk/by-partuuid/$TARGET_UUID"
                [ -s "$DEV_PATH" ] || exit 5

                mkdir -p /sysroot/boot
                mount "$DEV_PATH" /sysroot/boot || exit 6
                exit 0
            '';
        };
    };
# TODO: clean old code downstair
# mount -t efivarfs efivarfs /sys/firmware/efi/efivars
# od -An -t x1 -j 4 -N 2 /sys/firmware/efi/efivars/BootCurrent-8be4df61-93ca-11d2-aa0d-00e098032b8c | tr -d '\n'
}
