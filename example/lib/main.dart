import 'package:conversation_bubbles_example/models/contact.dart';
import 'package:conversation_bubbles_example/screens/chat_screen.dart';
import 'package:conversation_bubbles_example/screens/home_screen.dart';
import 'package:conversation_bubbles_example/services/bubbles_service.dart';
import 'package:conversation_bubbles_example/services/chats_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BubblesService.instance.init();
  await ChatsService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bubbles = BubblesService.instance;
    final chats = ChatsService.instance;

    return MaterialApp(
      initialRoute: '/',
      onGenerateInitialRoutes: (_) {
        return [
          if (!bubbles.isInBubble)
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          if (chats.launchContact != null)
            MaterialPageRoute(
              builder: (_) => ChatScreen(contact: chats.launchContact!),
            ),
        ];
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
            settings: settings,
          );
        } else if (settings.name == '/chat') {
          final args = settings.arguments;
          if (args is Contact) {
            return MaterialPageRoute(
              builder: (_) => ChatScreen(contact: args),
              settings: settings,
            );
          }
        }
        return null;
      },
    );
  }
}
