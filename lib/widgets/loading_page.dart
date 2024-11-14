import 'package:beta_app/modules/provider_setup/providers.dart';
import 'package:beta_app/utils/asset_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProviderInstance); // Renamed to avoid conflict with provider
    final logoPath = themeData.logoPath.isNotEmpty 
        ? themeData.logoPath 
        : AssetPaths.defaultLogoPath; // Use default logo if custom is unavailable

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                logoPath,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Loading...',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}