import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
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

  final _keyboardKey = GlobalKey();
  
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
        KeyboardLanguage.english => const DesktopEnglishKeyboardLayout(),
        KeyboardLanguage.arabic => const DesktopArabicKeyboardLayout(),
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
      key: _keyboardKey,
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.blue),
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

      // Handle language switch button press
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
      appBar: AppBar(
        title: const Text('Multilingual Keyboard Demo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // Language indicator card
                  Card(
                    elevation: 4,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _languageEmoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Language',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    _languageName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.isDesktop
                                ? 'Desktop Layout (QWERTY)'
                                : 'Mobile Layout',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.language_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Click 🌐 on keyboard to switch language',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: widget.onLanguageSwitch,
                            icon: const Icon(Icons.language),
                            label: Text(
                              'Switch to ${widget.currentLanguage == KeyboardLanguage.english ? "Arabic" : "English"}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Keyboard controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => keyboard.open(),
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Open Keyboard'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => keyboard.close(),
                        icon: const Icon(Icons.keyboard_hide),
                        label: const Text('Close Keyboard'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Text input examples
                  const Text(
                    'Try typing in different languages:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Single line text field
                  const OnscreenKeyboardTextField(
                    decoration: InputDecoration(
                      labelText: 'Name / الاسم',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email field (normal keyboard)
                  const OnscreenKeyboardTextField(
                    enableOnscreenKeyboard: false,
                    decoration: InputDecoration(
                      labelText: 'Email (system keyboard)',
                      hintText: 'email@example.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Multiline text field
                  const OnscreenKeyboardTextField(
                    decoration: InputDecoration(
                      labelText: 'Address / العنوان',
                      hintText: 'Enter your address',
                      prefixIcon: Icon(Icons.location_on),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Form field with validation
                  OnscreenKeyboardTextFormField(
                    formFieldKey: _formFieldKey,
                    decoration: const InputDecoration(
                      labelText: 'Message / الرسالة',
                      hintText: 'Enter a message (required)',
                      prefixIcon: Icon(Icons.message),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    onChanged: (value) {
                      _formFieldKey.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      if (value.length < 3) {
                        return 'Message must be at least 3 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Info card
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tips:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('• Tap on any text field to open the keyboard'),
                          const Text('• Press 🌐 button to switch between English and Arabic'),
                          const Text('• Press 123/أبج to switch to symbols mode'),
                          const Text('• Use Shift for capital letters (English)'),
                          const Text('• Keyboard automatically adapts to mobile/desktop'),
                        ],
                      ),
                    ),
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
