import 'dart:async';

import 'package:conversation_bubbles/conversation_bubbles.dart';
import 'package:conversation_bubbles_example/models/chat.dart';
import 'package:conversation_bubbles_example/models/message.dart';
import 'package:flutter/material.dart';

int _notifId = 0;
const _notifDetails = NotificationDetails(
  icon: 'ic_launcher',
  channelId: 'chat',
  channelName: 'Chat',
  channelDescription: 'Chat',
);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});

  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final plugin = ConversationBubbles();
  final ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  AssetImage('assets/${widget.chat.contact.name}.jpg'),
            ),
            const SizedBox(width: 8),
            Text(widget.chat.contact.name),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => Row(
          children: [
            if (!widget.chat.messages[i].isIncoming) const Spacer(),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: widget.chat.messages[i].isIncoming
                      ? Colors.blue.shade200
                      : Colors.green.shade200),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chat.messages[i].text),
                  if (widget.chat.messages[i].photo != null) ...[
                    const SizedBox(height: 4),
                    Image.asset('assets/${widget.chat.messages[i].photo}.jpg',
                        width: 100)
                  ]
                ],
              ),
            ),
          ],
        ),
        itemCount: widget.chat.messages.length,
      ),
      bottomNavigationBar: Container(
        decoration:
            const BoxDecoration(border: Border(top: BorderSide(width: 0.2))),
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: TextField(controller: ctrl, minLines: 1, maxLines: 3)),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (ctrl.text.isNotEmpty) {
                  final text = ctrl.text;
                  setState(() {
                    widget.chat.messages.add(Message(text: ctrl.text));
                    ctrl.text = '';
                  });
                  Timer(const Duration(seconds: 5), () {
                    final reply = widget.chat.contact.reply(text: text);
                    widget.chat.messages.add(reply);
                    plugin.showNotification(
                      id: _notifId,
                      title: widget.chat.contact.name,
                      body: reply.text,
                      details: _notifDetails,
                    );
                    if (mounted) setState(() {});
                  });
                }
              },
              child: const Icon(Icons.send),
            )
          ],
        ),
      ),
    );
  }
}
