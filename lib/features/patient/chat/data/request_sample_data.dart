import 'package:CuraDocs/features/patient/chat/entities/chat_data.dart';
import 'package:CuraDocs/features/patient/chat/entities/message.dart';

final List<ChatData> requestData = [
  RequestData(
    name: 'Dr.Hema Patel',
    specialization: 'Cardiologist',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    firstMessage: 'Hey, how are you?',
    time: '2:30 PM',
  ),
  RequestData(
    name: 'Dr. Ragheswari Jaiswal',
    specialization: 'Dermatologist',
    avatarUrl: 'https://i.pravatar.cc/150?img=2',
    firstMessage: 'I don\'t think I can join later in the afternoon',
    time: '1:45 PM',
  ),
];

final List<Message> messages = [
  Message(
    text: "I don't think I can join later in the afternoon 😔",
    sender: MessageSender.bot,
  ),
];
