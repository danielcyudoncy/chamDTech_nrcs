import 'dart:js_interop';
import 'package:web/web.dart' as web;

void suppressContextMenu() {
  web.document.addEventListener('contextmenu', (web.Event event) {
    event.preventDefault();
  }.toJS);
}
