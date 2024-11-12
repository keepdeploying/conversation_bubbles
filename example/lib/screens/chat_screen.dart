import 'package:conversation_bubbles_example/models/contact.dart';
import 'package:conversation_bubbles_example/models/message.dart';
import 'package:conversation_bubbles_example/services/bubbles_service.dart';
import 'package:conversation_bubbles_example/services/chats_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final Contact contact;

  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final bubbles = BubblesService.instance;
  final chats = ChatsService.instance;
  final scrollCtrl = ScrollController();
  final textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: bubbles.isInBubble
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: Navigator.of(context).canPop()
                    ? Navigator.of(context).pop
                    : () => Navigator.of(context).pushNamed('/'),
              ),
        titleSpacing: 0,
        title: Row(
          children: [
            if (bubbles.isInBubble) const SizedBox(width: 16),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/${widget.contact.name}.jpg'),
            ),
            const SizedBox(width: 8),
            Text(widget.contact.name),
          ],
        ),
        actions: [
          if (!bubbles.isInBubble)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () =>
                  bubbles.show(widget.contact, '', shouldAutoExpand: true),
            )
        ],
      ),
      body: StreamBuilder<List<Message>>(
        stream: chats.getMessages(widget.contact.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollCtrl.jumpTo(scrollCtrl.position.maxScrollExtent);
          });

          final messages = snapshot.data!;
          return ListView.builder(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) => Row(
              children: [
                if (!messages[i].isIncoming) const Spacer(),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: messages[i].isIncoming
                          ? Colors.blue.shade200
                          : Colors.green.shade200),
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(messages[i].text),
                      if (messages[i].photo != null) ...[
                        const SizedBox(height: 4),
                        Image.asset(
                          'assets/${messages[i].photo}.jpg',
                          width: 100,
                        )
                      ]
                    ],
                  ),
                ),
              ],
            ),
            itemCount: messages.length,
          );
        },
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
                child:
                    TextField(controller: textCtrl, minLines: 1, maxLines: 3)),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                if (textCtrl.text.isNotEmpty) {
                  await chats.send(
                      contact: widget.contact, text: textCtrl.text);
                  setState(() => textCtrl.text = '');
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
