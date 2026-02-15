import 'dart:html' as html;

void suppressContextMenu() {
  html.window.onContextMenu.listen((event) {
    event.preventDefault();
  });
}
