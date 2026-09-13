# tp_smapi 0.45 uses strncpy(), but Linux 7.2 removed the strncpy()
# declaration from <linux/string.h>, so compiling the module fails with
# "implicit declaration of function 'strncpy'" (a hard error with the
# newer toolchain). Swap it for memcpy(); the code already NUL-terminates
# the buffer on the next line.
#
# Revisit once upstream (or nixpkgs) carries a fix:
# https://github.com/linux-thinkpad/tp_smapi
final: prev:
let
  fix = old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace tp_smapi.c \
        --replace-fail 'strncpy(buf, (char *)row+offset, maxlen);' \
        'memcpy(buf, (char *)row+offset, maxlen);'
    '';
  };
in
{
  # All hosts use linuxPackages_latest, but patch both sets to be safe.
  linuxPackages = prev.linuxPackages.extend (lfinal: lprev: {
    tp_smapi = lprev.tp_smapi.overrideAttrs fix;
  });
  linuxPackages_latest = prev.linuxPackages_latest.extend (lfinal: lprev: {
    tp_smapi = lprev.tp_smapi.overrideAttrs fix;
  });
}
