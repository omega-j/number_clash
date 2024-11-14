import 'package:flutter/material.dart';

class LocalizationState {
  final Locale locale;
  final bool isLoading;

  LocalizationState({
    required this.locale,
    this.isLoading = false,
  });

  LocalizationState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LocalizationState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}