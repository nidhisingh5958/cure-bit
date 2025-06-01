import 'package:CureBit/features/doctor/chat/entities/_chat_data.dart';
import 'package:CureBit/features/doctor/chat/entities/_message.dart';

final List<DocChatData> chatData = [
  DocChatData(
      name: 'Dr. Ragheswari',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      lastMessage: 'I don\'t think I can join later in the afternoon',
      time: '1:45 PM',
      isOnline: true,
      isRequestAccepted: true),
  DocChatData(
    name: 'Dr. Madhu',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    lastMessage: 'I don\'t think I can join later in the afternoon',
    time: '1:45 PM',
    isOnline: true,
    isRequestAccepted: true,
  ),
  DocChatData(
    name: 'Dr. Hema',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    lastMessage: 'Hey, how are you?',
    time: '2:30 PM',
    isOnline: true,
    isRequestAccepted: true,
  ),
];

final List<DocMessage> messages = [
  DocMessage(
    text: "I don't think I can join later in the afternoon 😔",
    sender: MessageSender.bot,
  ),
  DocMessage(
    text: "Really why can't it be?",
    sender: MessageSender.user,
  ),
  DocMessage(
    imageUrl: "https://picsum.photos/200/200",
    text: "Recipe has not been completed",
    sender: MessageSender.bot,
  ),
  DocMessage(
    text: "oh yeah already",
    sender: MessageSender.user,
  ),
  DocMessage(
    text: "I'm really sorry, next time",
    sender: MessageSender.bot,
  ),
];
