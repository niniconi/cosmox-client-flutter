import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page<T> slideRightPage<T>(Widget child, LocalKey key) =>
    CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
            child: child,
          ),
    );

Page<T> slideUpPage<T>(Widget child, LocalKey key) => CustomTransitionPage<T>(
  key: key,
  child: child,
  transitionDuration: const Duration(milliseconds: 300),
  reverseTransitionDuration: const Duration(milliseconds: 250),
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
        child: FadeTransition(opacity: animation, child: child),
      ),
);

Page<T> fadePage<T>(Widget child, LocalKey key) => CustomTransitionPage<T>(
  key: key,
  child: child,
  transitionDuration: const Duration(milliseconds: 200),
  reverseTransitionDuration: const Duration(milliseconds: 200),
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(opacity: animation, child: child),
);

Page<T> instantPage<T>(Widget child, LocalKey key) =>
    NoTransitionPage<T>(key: key, child: child);
