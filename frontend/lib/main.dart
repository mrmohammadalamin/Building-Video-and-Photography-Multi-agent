import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'camera_screen.dart';
import 'services/mode_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModeService()),
      ],
      child: const GeminiPhotographyApp(),
    ),
  );
}

class GeminiPhotographyApp extends StatelessWidget {
  const GeminiPhotographyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ModeService>(
      builder: (context, modeService, _) {
        final themeColor = modeService.isPhotographer 
            ? Colors.deepPurpleAccent
            : Colors.redAccent;
        
        return MaterialApp(
          title: 'Gemini 3 Photography Agent',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: themeColor,
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.dark(
              primary: themeColor,
              secondary: themeColor,
            ),
          ),
          home: const CameraScreen(),
        );
      },
    );
  }
}
