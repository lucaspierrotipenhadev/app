// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Marca / Primária (Um tom violeta/azul elétrico moderno para redes sociais)
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color secondary = Color(0xFF00CEC9);

  // Status e Ações
  static const Color like = Color(0xFFE84393); // Cor para o botão de curtir
  static const Color error = Color(0xFFFF7675);
  static const Color success = Color(0xFF00B894);

  // Escala de Cinzas (Light)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  static const Color lightBorder = Color(0xFFDFE6E9);

  // Escala de Cinzas (Dark)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFF5F6FA);
  static const Color darkTextSecondary = Color(0xFFB2BEC3);
  static const Color darkBorder = Color(0xFF2D3436);
}