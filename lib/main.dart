import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/select_page.dart';
import 'page/projects/projects_page.dart';
import 'page/account/account_page.dart';
import 'page/dashboard/dashboard_page.dart';
import 'page/dashboard/pages/tasks_page.dart';

// Clave global para el Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  supabase.auth.onAuthStateChange.listen((AuthState data) async {
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      navigatorKey.currentState?.pushReplacementNamed('/proyects');
    } else if (event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState?.pushReplacementNamed('/login');
    } else if (event == AuthChangeEvent.initialSession) {
      if (session != null) {
        navigatorKey.currentState?.pushReplacementNamed('/proyects');
      } else {
        navigatorKey.currentState?.pushReplacementNamed('/login');
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mavale',
      navigatorKey: navigatorKey,
      theme: ThemeData.dark().copyWith(
        // Fondo principal basado en Telegram Dark
        scaffoldBackgroundColor: const Color(0xFF17212B),
        primaryColor: const Color(0xFF0088CC), // Azul Telegram
        // Estilos de texto personalizados
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          labelMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.grey, // Texto gris claro
          ),
        ),

        // Colores en Pantalla Splash
        splashColor: const Color.fromARGB(255, 0, 0, 0),
        // Fondo de los diálogos y tarjetas
        cardColor: const Color(0xFF232E3C), // Gris oscuro azulado
        // Estilos del menú contextual
        popupMenuTheme: PopupMenuThemeData(
          color: Color(0xFF232E3C), // Fondo del menú
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: TextStyle(
            color: Colors.white, // Color del texto
          ),
        ),

        // Estilos para iconos
        iconTheme: IconThemeData(color: Colors.grey[300]), // Color por defecto
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/select': (context) => const SelectPage(),
        '/account': (context) => const AccountPage(),
        '/proyects': (context) => const ProjectsPage(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DashboardPage(
            project: args['project'],
            index: args['index'],
            createdAt: args['createdAt'],
            createdTime: args['createdTime'],
            username: args['username'],
            projectId: args['id'],
          );
        },
        '/dashboard/tasks': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TasksPage(projectId: args['projectId']);
        },
      },
    );
  }
}
