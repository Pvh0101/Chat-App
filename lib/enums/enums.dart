enum FriendViewType { friends, friendRequests, groupView, allUsers }

enum MessageEnum { text, image, video, audio }

// extention convert MessageEnum to String
enum GroupType {
  private,
  public,
}

extension ConvertMessage on String {
  MessageEnum toMessageEnum() {
    switch (this) {
      case 'text':
        return MessageEnum.text;
      case 'image':
        return MessageEnum.image;
      case 'video':
        return MessageEnum.video;
      case 'audio':
        return MessageEnum.audio;
      default:
        return MessageEnum.text;
    }
  }
}
