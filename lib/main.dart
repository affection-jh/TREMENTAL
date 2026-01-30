import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tremental/screens/login_screen.dart';
import 'package:tremental/screens/splash_screen.dart';
import 'package:tremental/providers/overlay_provider.dart';
import 'package:tremental/widgets/overlay_widget.dart';
import 'package:tremental/services/auth_service.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OverlayProvider()),
      ],
      child: MaterialApp(
        title: 'Tremental',
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          // Always provide a single global OverlayWidget above all routes/screens.
          return OverlayWidget(child: child ?? const SizedBox.shrink());
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _hasShownSplash = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = snapshot.data;
        final isLoggedIn = currentUser != null;

        // 로그인되지 않았으면 로그인 화면 표시
        if (!isLoggedIn) {
          _hasShownSplash = false;
          return const LoginScreen();
        }

        // 로그인된 경우 스플래시 화면으로 이동 (모든 판단은 스플래시에서 수행)
        // _hasShownSplash 플래그는 스플래시가 한 번 표시된 후 네비게이션을 처리할 때까지 유지
        if (!_hasShownSplash) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasShownSplash = true;
              });
            }
          });
        }

        return const SplashScreen();
      },
    );
  }
}
