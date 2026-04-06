import 'package:flutter/material.dart';

/// Custom exception for app-specific errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => message;
}

/// Result wrapper for better error handling
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isLoading;

  Result.success(this.data) : error = null, isLoading = false;

  Result.error(this.error) : data = null, isLoading = false;

  Result.loading() : data = null, error = null, isLoading = true;

  bool get isSuccess => error == null && !isLoading;
  bool get isError => error != null;
}
