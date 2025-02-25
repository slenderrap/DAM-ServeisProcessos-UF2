import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app_data.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    await WindowManager.instance.ensureInitialized();

    var displays = PlatformDispatcher.instance.displays;
    Display currentDisplay = displays.first;

    double screenWidth =
        currentDisplay.size.width / currentDisplay.devicePixelRatio;
    double screenHeight =
        currentDisplay.size.height / currentDisplay.devicePixelRatio;

    double width = screenWidth * 0.8;
    double height = screenHeight * 0.8;
    double widthMin = 500.0;
    double heightMin = 300.0;
    double widthMax = 500.0;
    double heightMax = 300.0;

    width = min(max(width, widthMin), widthMax);
    height = min(max(height, heightMin), heightMax);

    await windowManager.setPreventClose(true);
    await windowManager.setPreventClose(false);

    await windowManager.setSize(Size(width, height));
    await windowManager.setMinimumSize(Size(widthMin, heightMin));
    await windowManager.setMaximumSize(Size(widthMax, heightMax));

    // Center the window
    double offsetX = (screenWidth - width) / 2;
    double offsetY = (screenHeight - height) / 2;
    await windowManager.setPosition(Offset(offsetX, offsetY));

    await windowManager.setTitle('Level Builder');

    await windowManager.waitUntilReadyToShow();
    await windowManager.show();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: const App(),
    ),
  );
}
