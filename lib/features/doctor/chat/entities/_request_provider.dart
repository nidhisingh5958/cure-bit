import 'package:CuraDocs/features/doctor/chat/entities/_chat_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestNotifier extends Notifier<List<DocRequestData>> {
  @override
  List<DocRequestData> build() {
    // Load from backend or mock data
    return [
      DocRequestData(
        name: "John",
        avatarUrl: "https://...",
        firstMessage: "Hey, can we talk?",
        time: "12:00 PM",
      ),
      // more requests
    ];
  }

  void acceptRequest(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(isRequestAccepted: true)
        else
          state[i],
    ];
  }
}

final requestProvider = NotifierProvider<RequestNotifier, List<DocRequestData>>(
    () => RequestNotifier());
