# Workaround for https://github.com/NixOS/nixpkgs/issues/575192
#
# Since the kmodigest change, `aggregateModules` concatenates one <module>.ko.cer
# per module in the tree. Kbuild only emits that certificate on `modules_install`,
# so packages that copy their .ko by hand break the kernel-modules tree with
# "cat: ....ko.cer: No such file or directory" (exit 123).
#
# Install through Kbuild instead. Module signatures are not enforced (nixpkgs
# leaves MODULE_SIG_FORCE off), so this keeps the build working and the
# certificate list complete rather than enabling verification.
#
# Drop this overlay once nixpkgs carries the per-package fixes; they are already
# on master.
final: prev:
let
  patch =
    lfinal: lprev:
    let
      inherit (lfinal) kernel kernelModuleMakeFlags;
      buildDir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

      # Install the module built in $PWD through Kbuild, so the signing rule
      # emits the .ko.cer that aggregateModules concatenates.
      kbuildInstall = modDir: extra: ''
        runHook preInstall
        flags=()
        concatTo flags makeFlags makeFlagsArray
        KBUILD_NOPEDANTIC=1 make -C ${buildDir} M="$PWD" "''${flags[@]}" \
          INSTALL_MOD_PATH="$out" INSTALL_MOD_DIR=${modDir} DEPMOD=true modules_install
        ${extra}
        runHook postInstall
      '';
    in
    {
      acpi_call = lprev.acpi_call.overrideAttrs (_: {
        installPhase = kbuildInstall "misc" ''
          install -D -m755 examples/turn_off_gpu.sh $out/bin/test_discrete_video_off.sh
        '';
      });

      zenpower = lprev.zenpower.overrideAttrs (old: {
        makeFlags = kernelModuleMakeFlags ++ old.makeFlags;
        installPhase = kbuildInstall "kernel/drivers/hwmon/zenpower" "";
      });

      ryzen-smu = lprev.ryzen-smu.overrideAttrs (old: {
        makeFlags = kernelModuleMakeFlags ++ old.makeFlags;
        installPhase = kbuildInstall "kernel/drivers/ryzen_smu" ''
          # nixpkgs builds monitor_cpu in a derivation private to the package, so
          # the replacement install phase has to build it as well.
          make -C userspace
          install userspace/monitor_cpu -Dm755 -t $out/bin
        '';
      });

      ddcci-driver = lprev.ddcci-driver.overrideAttrs (_: {
        installPhase = ''
          runHook preInstall
          flags=()
          concatTo flags makeFlags makeFlagsArray
          for d in ddcci ddcci-backlight; do
            KBUILD_NOPEDANTIC=1 make -C ${buildDir} M="$PWD/$d" "''${flags[@]}" \
              INSTALL_MOD_PATH="$out" INSTALL_MOD_DIR=extra DEPMOD=true modules_install
          done
          runHook postInstall
        '';
      });
    };
in
{
  # All hosts use linuxPackages_latest, but patch both sets to be safe.
  linuxPackages = prev.linuxPackages.extend patch;
  linuxPackages_latest = prev.linuxPackages_latest.extend patch;
}
