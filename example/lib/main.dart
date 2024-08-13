import 'dart:async';

import 'package:conversation_bubbles/conversation_bubbles.dart';
import 'package:conversation_bubbles_example/models/chat.dart';
import 'package:conversation_bubbles_example/screens/chat_screen.dart';
import 'package:conversation_bubbles_example/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _conversationBubblesPlugin = ConversationBubbles();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      await _conversationBubblesPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {/* */}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments;
          if (args is Chat) {
            return MaterialPageRoute(
              builder: (_) => ChatScreen(chat: args),
              settings: settings,
            );
          }
        }
        return null;
      },
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}
