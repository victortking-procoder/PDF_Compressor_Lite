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
  AdService? _adService;
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    // Initialize AdMob FIRST and WAIT for it (critical for ads to work)
    try {
      debugPrint('🚀 Starting AdMob initialization...');
      
      // Configure AdMob for test mode
      final params = RequestConfiguration(
        testDeviceIds: ['YOUR_TEST_DEVICE_ID'], // Add your device ID for testing
      );
      MobileAds.instance.updateRequestConfiguration(params);
      
      // Initialize AdMob SDK
      final initFuture = MobileAds.instance.initialize();
      await initFuture;
      
      debugPrint('✅ AdMob initialized successfully!');
      
      // Give extra time for SDK to be fully ready
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('✅ AdMob ready to load ads');
      
    } catch (e) {
      debugPrint('❌ AdMob initialization error: $e');
      // Retry once after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      try {
        debugPrint('🔄 Retrying AdMob initialization...');
        await MobileAds.instance.initialize();
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ AdMob initialized successfully on retry!');
      } catch (e2) {
        debugPrint('❌ AdMob initialization failed again: $e2');
      }
    }
    
    // Initialize storage service
    final storageService = StorageService();
    try {
      await storageService.init().timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Storage initialization error: $e');
    }
    
    // Initialize ad service
    final adService = AdService();
    // AdService.init() will be called from HomeScreen AFTER MobileAds is ready
    
    // Mark as initialized and rebuild
    if (mounted) {
      setState(() {
        _storageService = storageService;
        _adService = adService;
        _initialized = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_initialized || _storageService == null || _adService == null) {
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
        ChangeNotifierProvider<AdService>.value(value: _adService!),
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
