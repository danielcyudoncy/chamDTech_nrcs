import 'context_menu_stub.dart'
    if (dart.library.html) 'context_menu_web.dart';

void disableBrowserContextMenu() {
  suppressContextMenu();
}
