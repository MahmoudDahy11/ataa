import 'package:flutter/material.dart';

@immutable
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashNavigateToOnboarding extends SplashState {}

class SplashNavigateToAuth extends SplashState {}

class SplashNavigateHome extends SplashState {}

class SplashNavigateToProfile extends SplashState {}

class SplashNavigateToRegister extends SplashState {}
