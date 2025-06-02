import 'package:CureBit/features/patient/curebot/entities/message_bot.dart';

class MessageGroup {
  final List<Message> messages;
  final MessageSender sender;

  MessageGroup({required this.messages, required this.sender});
}
