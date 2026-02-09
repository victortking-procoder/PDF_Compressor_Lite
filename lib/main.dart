import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/compression_service.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run app immediately, initialize services in background
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  StorageService? _storageService;
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    // Initialize services with timeouts to prevent hanging
    
    // Initialize AdMob in background (don't wait for it)
    MobileAds.instance.initialize().timeout(
      const Duration(seconds: 5),
    ).catchError((e) {
      debugPrint('AdMob initialization error: $e');
    });
    
    // Initialize storage service
    final storageService = StorageService();
    try {
      await storageService.init().timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Storage initialization error: $e');
    }
    
    // Mark as initialized and rebuild
    if (mounted) {
      setState(() {
        _storageService = storageService;
        _initialized = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_initialized || _storageService == null) {
      // Show simple loading screen
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing...'),
              ],
            ),
          ),
        ),
      );
    }
    
    return MultiProvider(
      providers: [
        Provider<AdService>(create: (_) => AdService()),
        ChangeNotifierProvider<StorageService>.value(value: _storageService!),
        Provider<CompressionService>(create: (_) => CompressionService()),
      ],
      child: const PDFCompressorApp(),
    );
  }
}

class PDFCompressorApp extends StatelessWidget {
  const PDFCompressorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Compressor Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
