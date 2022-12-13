class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? dateTime;

  ChatRoomModel({this.chatroomid, this.participants, this.lastMessage,this.dateTime});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    dateTime= map["datetime"].toDate() ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastMessage,
      "datetime":dateTime,
    };
  }
}
