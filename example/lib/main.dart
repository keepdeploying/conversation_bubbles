import 'package:conversation_bubbles_example/models/chat.dart';
import 'package:conversation_bubbles_example/screens/chat_screen.dart';
import 'package:conversation_bubbles_example/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
