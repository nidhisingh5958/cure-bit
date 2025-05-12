import 'package:CuraDocs/features/doctor/chat/data/request_sample_data.dart';
import 'package:CuraDocs/features/doctor/chat/entities/_chat_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestNotifier extends Notifier<List<DocRequestData>> {
  @override
  List<DocRequestData> build() {
    // Initialize with sample request data
    return docRequestData;
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

  void acceptRequestFromUser(String name) {
    state = state.map((request) {
      if (request.name == name) {
        return request.copyWith(isRequestAccepted: true);
      }
      return request;
    }).toList();
  }
}

final requestProvider = NotifierProvider<RequestNotifier, List<DocRequestData>>(
    () => RequestNotifier());
