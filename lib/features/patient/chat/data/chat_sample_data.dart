import 'package:CuraDocs/features/patient/chat/entities/chat_data.dart';
import 'package:CuraDocs/features/patient/chat/entities/message.dart';

final List<ChatData> chatData = [
  ChatData(
    name: 'Dr. Hema',
    specialization: 'Cardiologist',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    lastMessage: 'Hey, how are you?',
    time: '2:30 PM',
    isOnline: true,
  ),
  ChatData(
    name: 'Dr. Ragheswari',
    specialization: 'Dermatologist',
    avatarUrl: 'https://i.pravatar.cc/150?img=2',
    lastMessage: 'I don\'t think I can join later in the afternoon',
    time: '1:45 PM',
    isOnline: true,
  ),
  ChatData(
    name: 'Dr. Madhu',
    specialization: 'Pediatrition',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    lastMessage: 'I don\'t think I can join later in the afternoon',
    time: '1:45 PM',
    isOnline: true,
  ),
];

final List<Message> messages = [
  Message(
    text: "I don't think I can join later in the afternoon 😔",
    sender: MessageSender.bot,
  ),
  Message(
    text: "Really why can't it be?",
    sender: MessageSender.user,
  ),
  Message(
    imageUrl: "https://picsum.photos/200/200",
    text: "Recipe has not been completed",
    sender: MessageSender.bot,
  ),
  Message(
    text: "oh yeah already",
    sender: MessageSender.user,
  ),
  Message(
    text: "I'm really sorry, next time",
    sender: MessageSender.bot,
  ),
];
