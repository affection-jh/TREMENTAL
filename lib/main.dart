import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tremental/screens/main_screen.dart';
import 'package:tremental/providers/overlay_provider.dart';
import 'package:tremental/widgets/overlay_widget.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OverlayProvider(),
      child: MaterialApp(
        title: 'Tremental',
        theme: AppTheme.lightTheme,
        home: OverlayWidget(child: const MainScreen()),
      ),
    );
  }
}
