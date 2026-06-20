import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'services/supabase_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const EbroApp());
}

class EbroApp extends StatefulWidget {
  const EbroApp({super.key});

  @override
  State<EbroApp> createState() => _EbroAppState();
}

class _EbroAppState extends State<EbroApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ebro',
      debugShowCheckedModeBanner: false,
      theme: buildEbroTheme(),
      home: StreamBuilder<AuthState>(
        stream: SupabaseService.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = SupabaseService.client.auth.currentSession;
          if (session != null) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
