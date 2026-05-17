{ config, lib, pkgs, vars, ... }: {
    boot.initrd.systemd.services.smart-boot-mount = {
        description = "Mount /boot based on UEFI BootCurrent/Boot000X variables only";
        # After the /dev/* and efivarfs
        wants = [ "systemd-udev-settle.service" ]; # Run udev-settle if it doesn't run
        after = [
            "systemd-udev-settle.service"
            "modprobe@fivarfs.service"
        ];
        wantedBy = [ "initrd-fs.target" ]; # Run me when initrd-fs ends
        # Before root switching
        before = [
            "local-fs-pre.target"
            "initrd-fs.target"
        ];
        unitConfig.DefaultDependencies = false; # At initrd only

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
        };

        script = let
            od = "${pkgs.coreutils}/bin/od";
            tr = "${pkgs.coreutils}/bin/tr";
            mount = "${pkgs.util-linux}/bin/mount";
            mountpoint = "${pkgs.util-linux}/bin/mountpoint";
        in ''
            # Fast exit if we are booting not in the UEFI-mode or /boot is already mounted
            [ -d "/sysroot/boot" ] || exit -1
            [ -d "/sys/firmware/efi/efivars" ] || exit 1
            # Check /sys/firmware/efi/efivars
            ${mountpoint} -q /sys/firmware/efi/efivars || ${mount} -t efivarfs efivarfs /sys/firmware/efi/efivars 2>/dev/null

            BOOT_HEX=$(${od} -An -t x1 -j 4 -N 2 /sys/firmware/efi/efivars/BootCurrent-8be4df61-93ca-11d2-aa0d-00e098032b8c | ${tr} -d ' \n')
            [ -z "$BOOT_HEX" ] && exit 2

            BOOT_NUM="''${BOOT_HEX:2:2}''${BOOT_HEX:0:2}" # Little Endian fixing

            BOOT_VAR="/sys/firmware/efi/efivars/Boot''${BOOT_NUM}-8be4df61-93ca-11d2-aa0d-00e098032b8c"
            VAR_HEX=$(${od} -An -v -t x1 "$BOOT_VAR" 2>/dev/null | ${tr} -d ' \n')

            PART_OFFSET_STR=''${VAR_HEX#*04012a00}
            [ "$PART_OFFSET_STR" == "$VAR_HEX" ] && exit 3

            RAW_UUID=''${PART_OFFSET_STR:24:32}
            [ ''${#RAW_UUID} -n 32 ] && exit 4
            # Little Endian fixing
            TARGET_UUID="''${RAW_UUID:6:2}''${RAW_UUID:4:2}''${RAW_UUID:2:2}''${RAW_UUID:0:2}-''${RAW_UUID:10:2}''${RAW_UUID:8:2}-''${RAW_UUID:14:2}''${RAW_UUID:12:2}-''${RAW_UUID:16:4}-''${RAW_UUID:20:12}"

            DEV_PATH="/dev/disk/by-partuuid/$TARGET_UUID"
            [ -s "$DEV_PATH" ] || exit 5

            mkdir -p /sysroot/boot
            ${mount} "$DEV_PATH" /sysroot/boot || exit 6
            exit 0
        '';
    };
# TODO: clean old code downstair
# mount -t efivarfs efivarfs /sys/firmware/efi/efivars
# od -An -t x1 -j 4 -N 2 /sys/firmware/efi/efivars/BootCurrent-8be4df61-93ca-11d2-aa0d-00e098032b8c | tr -d '\n'
}
