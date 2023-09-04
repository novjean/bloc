import 'package:bloc/db/entity/lounge_chat.dart';
import 'package:bloc/helpers/dummy.dart';

class DummyData {
  static LoungeChat dummyPhotoChat() {
    LoungeChat photoChat = Dummy.getDummyLoungeChat();
    photoChat = photoChat.copyWith(userId: 'MR5NNuUuSraGk9RixvZzQo4e0ZX2',
      message: 'https://firebasestorage.googleapis.com/v0/b/bloc-novatech.appspot.com/o/chat_image%2Fvw3vZ2oqp65RQGbFmkLQmSpvYhJI.jpg?alt=media&token=64d74eaa-9171-4f03-96b8-ce1c04964c26, We use indexOf to find the index of the first occurrence of the delimiter (, in this case) in the string. If the delimiter is not found, indexOf returns -1.',
      loungeId: 'l208UuhU2B5X0BkzZcxebGDRxSxg',
      loungeName: '🍹 gin and jazz 🎷',
      time: 1693842969344,
      type: 'image',
      userImage: 'https://firebasestorage.googleapis.com/v0/b/bloc-novatech.appspot.com/o/user_image%2FQnsR1jOM61b1zShmhBPPVOIGuBFx.jpg?alt=media&token=bc486ee9-4cdc-4119-8938-48c9ec0f51c7',
      userName: 'bloc',
    );
    return photoChat;
  }
}