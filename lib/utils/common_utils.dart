import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../modules/provider_setup/providers.dart';

class CommonUtils {
  // #region Conversion Logic

  static double convertToElapsedTimeInSeconds(
      double timestampInSecondsFromEpochUtc,
      double sessionStartTimeInSecondsFromEpochUtc) {
    return timestampInSecondsFromEpochUtc -
        sessionStartTimeInSecondsFromEpochUtc;
  }

  static double convertMillisecondsToSeconds(double millisecondsCount) {
    return millisecondsCount / 1000;
  }

  static double getSessionStartTimeInSecondsFromEpochUtc(
      List<FlSpot> collectedData) {
    return collectedData.isNotEmpty ? collectedData.first.x : 0;
  }

  static Color parseColor(String colorString) {
    return Color(int.parse(colorString.replaceFirst('#', '0xff')));
  }

  static Color getColorFromJson(Map<String, dynamic> themeData, String key) {
    final colorString = themeData[key] as String?;
    if (colorString != null) {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    }
    return Colors.transparent;
  }

  static int parseColorToInt(String colorString) {
    if (colorString.startsWith('#')) {
      colorString = colorString.substring(1);
    }
    return int.parse('0xFF$colorString');
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  // #endRegion Conversion Logic

  // #region View Range Logic

  static bool isInViewRange(
      double timestampInMillisecondsFromEpoch,
      double sessionStartInMillisecondsFromEpoch,
      double viewStartInSecondsElapsed,
      double viewEndInSecondsElapsed) {
    double elapsedTimeInSeconds = convertToElapsedTimeInSeconds(
        timestampInMillisecondsFromEpoch, sessionStartInMillisecondsFromEpoch);

    return elapsedTimeInSeconds >= viewStartInSecondsElapsed &&
        elapsedTimeInSeconds <= viewEndInSecondsElapsed;
  }

  static double interpolateY(FlSpot beforeStart, FlSpot afterStart) {
    return (beforeStart.y + afterStart.y) / 2;
  }

  // #endRegion View Range Logic

  // #region Time Formatting Logic

  static String formatToTimestampFromSecondsFromEpochUtc(
      double secondsSinceEpoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
            secondsSinceEpoch.toInt() * 1000,
            isUtc: true)
        .toLocal();

    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  // #endRegion Time Formatting Logic

  // #region Asset Loading Logic

  static Future<Image?> getLogoImageForApp(
      String path, WidgetRef ref) async {
    final logger = ref.read(loggingProvider);
    try {
      await rootBundle.load(path);
      logger.logInfo('Logo loaded successfully from $path');
      return Image.asset(path, width: 23, height: 23, fit: BoxFit.cover);
    } catch (e) {
      logger.logError('Exception when loading logo: $e');
      return null;
    }
  }

  // #endRegion Asset Loading Logic

  static String getUserLocale() {
    return Intl.defaultLocale ?? 'en_US';
  }

  static String getUserTimeZone() {
    return DateTime.now().timeZoneName;
  }
}