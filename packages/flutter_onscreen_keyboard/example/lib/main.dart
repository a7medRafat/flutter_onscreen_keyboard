import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';

void main() {
  runApp(const App());
}

enum KeyboardLanguage { english, arabic }

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  KeyboardLanguage _currentLanguage = KeyboardLanguage.english;

  // Determine if we're on desktop or mobile
  bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  KeyboardLayout _getLayout() {
    if (_isDesktop) {
      return switch (_currentLanguage) {
        KeyboardLanguage.english => const DesktopEnglishKeyboardLayout(),
        KeyboardLanguage.arabic => const DesktopArabicKeyboardLayout(),
      };
    } else {
      return switch (_currentLanguage) {
        KeyboardLanguage.english => const MobileKeyboardLayout(),
        KeyboardLanguage.arabic => const MobileKeyboardLayout(),
      };
    }
  }

  void _switchLanguage() {
    setState(() {
      _currentLanguage = switch (_currentLanguage) {
        KeyboardLanguage.english => KeyboardLanguage.arabic,
        KeyboardLanguage.arabic => KeyboardLanguage.english,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Removed the 'key' parameter from builder since it's no longer supported
      builder: OnscreenKeyboard.builder(
        width: (context) => MediaQuery.sizeOf(context).width / 2,
        layout: _getLayout(),
      ),

      home: HomeScreen(
        currentLanguage: _currentLanguage,
        onLanguageSwitch: _switchLanguage,
        isDesktop: _isDesktop,
      ),
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSwitch,
    required this.isDesktop,
  });

  final KeyboardLanguage currentLanguage;
  final VoidCallback onLanguageSwitch;
  final bool isDesktop;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final keyboard = OnscreenKeyboard.of(context);
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    // listener for raw keyboard events
    keyboard.addRawKeyDownListener(_listener);
  }

  @override
  void dispose() {
    keyboard.removeRawKeyDownListener(_listener);
    super.dispose();
  }

  void _listener(OnscreenKeyboardKey key) {
    if (key is TextKey) {
      log('key: "${key.primary}"');
    } else if (key is ActionKey) {
      log('action: ${key.name}');

      if (key.name == 'language') {
        widget.onLanguageSwitch();
      }
    }
  }

  String get _languageName {
    return switch (widget.currentLanguage) {
      KeyboardLanguage.english => 'English',
      KeyboardLanguage.arabic => 'Arabic (العربية)',
    };
  }

  String get _languageEmoji {
    return switch (widget.currentLanguage) {
      KeyboardLanguage.english => '🇬🇧',
      KeyboardLanguage.arabic => '🇸🇦',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 300,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Language indicator
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _languageEmoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Language',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                  Text(
                                    _languageName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.isDesktop
                                ? 'Desktop Layout'
                                : 'Mobile Layout',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.language_rounded,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Click 🌐 on keyboard to switch',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () => keyboard.open(),
                    child: const Text('Open Keyboard'),
                  ),
                  TextButton(
                    onPressed: () => keyboard.close(),
                    child: const Text('Close Keyboard'),
                  ),

                  // TextField that opens the keyboard on focus
                  const OnscreenKeyboardTextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),

                  // normal keyboard
                  const OnscreenKeyboardTextField(
                    enableOnscreenKeyboard: false,
                    decoration: InputDecoration(
                      labelText: 'Email (normal keyboard)',
                    ),
                  ),

                  // multiline TextField
                  const OnscreenKeyboardTextField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                    ),
                    maxLines: null,
                  ),

                  // form field
                  OnscreenKeyboardTextFormField(
                    formFieldKey: _formFieldKey,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                    ),
                    onChanged: (value) {
                      _formFieldKey.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
