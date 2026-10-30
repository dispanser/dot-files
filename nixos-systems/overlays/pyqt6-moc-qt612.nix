# python3.14-pyqt6 fails to import on darwin with Qt 6.12:
#   dlopen(...QtCore.abi3.so): symbol not found in flat namespace
#   '__ZN13QPyTableRange16staticMetaObjectE'
# Qt 6.12's moc no longer resolves QT_VERSION from <qglobal.h>, so the
# `#if QT_VERSION >= 0x060a00` guard in qpycore_qrangemodel.h silently hides
# the Q_OBJECT classes from moc ("No relevant classes found") and the
# QPy*Range::staticMetaObject symbols are missing at load time. We always
# build against Qt >= 6.10, so make the guard unconditional.
# Remove once nixpkgs works around this (python3Packages.pyqt6 with Qt 6.12).
final: prev: {
  python3 = prev.python3.override {
    packageOverrides = pfinal: pprev: {
      pyqt6 = pprev.pyqt6.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace qpy/QtCore/qpycore_qrangemodel.h \
            --replace-fail "#if QT_VERSION >= 0x060a00" "#if 1"
        '';
      });
    };
  };
}
