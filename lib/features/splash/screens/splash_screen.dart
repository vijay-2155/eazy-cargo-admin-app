import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:eaze_my_cargo/core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  LottieComposition? _composition;
  final Map<String, ui.Image> _decodedImages = {};
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
    ));
    _loadLottie();
  }

  Future<void> _loadLottie() async {
    // 1. Load and parse the composition
    final data = await rootBundle.load('assets/lottie/splash_animation.json');
    final composition = await LottieComposition.fromByteData(data);

    // 2. Pre-decode every embedded base64 image into a dart:ui.Image
    for (final asset in composition.images.values) {
      final ref = asset.fileName;
      if (ref.startsWith('data:')) {
        final comma = ref.indexOf(',');
        if (comma != -1) {
          try {
            final bytes = base64Decode(ref.substring(comma + 1));
            final codec = await ui.instantiateImageCodec(bytes);
            final frame = await codec.getNextFrame();
            _decodedImages[asset.id] = frame.image;
          } catch (_) {
            // skip undecodable frames
          }
        }
      }
    }

    if (!mounted) return;

    setState(() => _composition = composition);

    // 3. Navigate after full duration + small buffer
    final duration = composition.duration + const Duration(milliseconds: 300);
    _navTimer = Timer(duration, _navigate);
  }

  void _navigate() {
    if (mounted) context.go(AppConstants.routeLogin);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    // Release ui.Image resources
    for (final img in _decodedImages.values) {
      img.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show black screen while images are decoding
    if (_composition == null) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Lottie(
          composition: _composition!,
          fit: BoxFit.fill,
          repeat: false,
          delegates: LottieDelegates(
            // Synchronous lookup — images already decoded
            image: (composition, asset) => _decodedImages[asset.id],
          ),
        ),
      ),
    );
  }
}
