import 'dart:async';

import 'package:conversation_bubbles_example/models/contact.dart';
import 'package:conversation_bubbles_example/models/message.dart';
import 'package:conversation_bubbles_example/services/bubbles_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ChatsService {
  late final Isar _db;

  static final instance = ChatsService._();

  ChatsService._();

  Message _reply({required Contact contact, required String text}) {
    final Contact(:id, :name) = contact;
    return switch (name) {
      'Cat' => Message(contactId: id, text: 'Meow'),
      'Dog' => Message(contactId: id, text: 'Woof woof!!'),
      'Parrot' => Message(contactId: id, text: text),
      'Sheep' =>
        Message(contactId: id, text: 'Look at me!', photo: 'sheep_full'),
      _ => throw Exception('Unknown contact: $name'),
    };
  }

  Future<void> _setupContacts() async {
    await _db.writeTxn(() async {
      for (final name in ['Cat', 'Dog', 'Parrot', 'Sheep']) {
        await _db.contacts.put(Contact(name: name));
        final contact =
            await _db.contacts.filter().nameEqualTo(name).findFirst();
        await _db.messages.putAll([
          Message(contactId: contact!.id, text: 'Send me a message'),
          Message(contactId: contact.id, text: 'I will reply in 5 seconds')
        ]);
      }
    });
  }

  Stream<List<Contact>> get contacts => _db.contacts
      .watchLazy(fireImmediately: true)
      .asyncMap((_) => _db.contacts.where().findAll());

  Future<void> clear() async {
    await _db.writeTxn(_db.clear);
    await _setupContacts();
  }

  Future<Contact?> getContact(int id) => _db.contacts.get(id);

  Stream<List<Message>> getMessages(int contactId) {
    return _db.messages
        .where()
        .contactIdEqualTo(contactId)
        .build()
        .watch(fireImmediately: true);
  }

  Future<void> init() async {
    _db = Isar.instanceNames.isEmpty
        ? await Isar.open(
            [ContactSchema, MessageSchema],
            directory: (await getApplicationDocumentsDirectory()).path,
            inspector: true,
          )
        : Isar.getInstance()!;

    if (await _db.contacts.count() == 0) await _setupContacts();
  }

  Future<void> send({
    required Contact contact,
    required String text,
  }) async {
    await _db.writeTxn(() async {
      await _db.messages.put(
        Message(contactId: contact.id, isIncoming: false, text: text),
      );
    });

    Timer(const Duration(seconds: 5), () async {
      final reply = _reply(contact: contact, text: text);
      await BubblesService.instance.show(contact, reply.text);
      await _db.writeTxn(() async => await _db.messages.put(reply));
    });
  }
}
