import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/symptom_screen.dart';
import 'services/api_service.dart';
import 'services/accessibility_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AccessibilityService(),
      child: const MediWayApp(),
    ),
  );
}

class MediWayApp extends StatefulWidget {
  const MediWayApp({super.key});

  @override
  State<MediWayApp> createState() => _MediWayAppState();
}

class _MediWayAppState extends State<MediWayApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccessibilityService>().loadAccessibility();
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (result) {
          String command =
              result.recognizedWords.toLowerCase();
          _handleVoiceCommand(command);
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _handleVoiceCommand(String command) {
    if (command.contains("login")) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
            builder: (_) =>
                const AuthChoiceScreen()),
      );
    }

    if (command.contains("symptom")) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
            builder: (_) =>
                const SymptomScreen()),
      );
    }

    if (command.contains("back")) {
      navigatorKey.currentState?.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessibility =
        context.watch<AccessibilityService>();

    if (accessibility.isBlind && !_isListening) {
      _startListening();
    }

    final bool highContrast =
        accessibility.highContrast;

    final Brightness brightness =
        highContrast ? Brightness.dark : Brightness.light;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MediWay',

      theme: ThemeData(
        useMaterial3: true,
        brightness: brightness,

        // ================= COLOR SCHEME =================
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: brightness,
        ),

        // ================= BACKGROUND =================
        scaffoldBackgroundColor: brightness == Brightness.dark
            ? const Color(0xFF121212)
            : const Color(0xFFF4F8FB),

        // ================= TEXT THEME =================
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize:
                accessibility.largeText ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize:
                accessibility.largeText ? 22 : 20,
            fontWeight: FontWeight.w600,
            color: brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize:
                accessibility.largeText ? 20 : 16,
            color: brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize:
                accessibility.largeText ? 18 : 14,
            color: brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
          ),
        ),

        // ================= APP BAR =================
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),

        // ================= CARD THEME =================
        cardTheme: CardThemeData(
          elevation: 3,
          color: brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.symmetric(
              vertical: 8),
        ),

        // ================= INPUT FIELD THEME =================
        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor:
              brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          labelStyle: TextStyle(
            color: brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),

        // ================= BUTTON THEME =================
        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF1E88E5),
            foregroundColor:
                Colors.white,
            padding:
                const EdgeInsets.symmetric(
                    vertical: 16),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
            textStyle:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),

      builder: (context, child) {
        return Stack(
          children: [
            child!,

            // 🎤 Voice button for blind users
            if (accessibility.isBlind)
              Positioned(
                bottom: 30,
                right: 20,
                child:
                    FloatingActionButton(
                  backgroundColor:
                      _isListening
                          ? Colors.red
                          : const Color(
                              0xFF1E88E5),
                  onPressed: () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  },
                  child: Icon(
                    _isListening
                        ? Icons.mic
                        : Icons.mic_none,
                  ),
                ),
              ),
          ],
        );
      },

      home: const StartupScreen(),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() =>
      _StartupScreenState();
}

class _StartupScreenState
    extends State<StartupScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    await ApiService.loadToken();

    if (ApiService.token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const SymptomScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AuthChoiceScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(
          color: Color(0xFF1E88E5),
        ),
      ),
    );
  }
}