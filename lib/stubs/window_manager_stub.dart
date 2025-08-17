// lib/stubs/window_manager_stub.dart
// This is a stub file for web platform where window_manager is not available

class WindowManager {
  Future<void> ensureInitialized() async {}

  Future<void> waitUntilReadyToShow(WindowOptions options, Function callback) async {}

  Future<void> show() async {}

  Future<void> focus() async {}
}

class WindowOptions {
  final Size? size;
  final Size? minimumSize;
  final Size? maximumSize;
  final bool? center;
  final dynamic backgroundColor;
  final bool? skipTaskbar;
  final TitleBarStyle? titleBarStyle;

  WindowOptions({
    this.size,
    this.minimumSize,
    this.maximumSize,
    this.center,
    this.backgroundColor,
    this.skipTaskbar,
    this.titleBarStyle,
  });
}

class Size {
  final double width;
  final double height;

  Size(this.width, this.height);
}

enum TitleBarStyle {
  normal,
  hidden,
}

// Export a singleton instance
final windowManager = WindowManager();