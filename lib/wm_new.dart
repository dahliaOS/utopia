/// The old import to use the newly created WM API.
///
/// The library received a big API overhaul way before being published and in order
/// not to break the projects depending on the old API this new import was created
/// to opt-in for the latest API.
///
/// It is now kept only for compatibility and will be eventually removed in later versions.
@Deprecated(
  "This file is kept only for compatibily. Use the new package:utopia_wm/wm.dart file instead",
)
library utopia_wm_dep;

export 'package:utopia_wm/wm.dart';
