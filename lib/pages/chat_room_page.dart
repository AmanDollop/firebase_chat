import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/main.dart';
import 'package:firebase_chat/modals/chat_room_modal.dart';
import 'package:firebase_chat/modals/mssegae_modal.dart';
import 'package:firebase_chat/modals/userModel.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.2),
      body: Stack(
        children: [
          Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFBAD33),
                            Color(0xFFF2653A),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                              splashRadius: 25,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_left,
                                  color: Colors.white,
                                  size: 30,
                                )),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(
                                widget.targetUser.profilepic.toString()),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            widget.targetUser.fullname.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("chatrooms")
                              .doc(widget.chatroom.chatroomid)
                              .collection("messages")
                              .orderBy("createdon", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              if (snapshot.hasData) {
                                QuerySnapshot dataSnapshot =
                                    snapshot.data as QuerySnapshot;

                                return ListView.builder(
                                  reverse: true,
                                  itemCount: dataSnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    MessageModel currentMessage =
                                        MessageModel.fromMap(
                                            dataSnapshot.docs[index].data()
                                                as Map<String, dynamic>);

                                    return Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              (currentMessage.sender ==
                                                      widget.userModel.uid)
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                          children: [
                                            currentMessage.sender ==
                                                    widget.userModel.uid
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10,
                                                    ),
                                                    decoration: const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(6),
                                                        topRight:
                                                            Radius.circular(6),
                                                        bottomLeft:
                                                            Radius.circular(6),
                                                      ),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFFFBAD33),
                                                          Color(0xFFF2653A),
                                                        ],
                                                      ),
                                                    ),
                                                    child: SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                        currentMessage.text
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 200,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10,
                                                    ),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(6),
                                                        topRight:
                                                            Radius.circular(6),
                                                        bottomRight:
                                                            Radius.circular(6),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      currentMessage.text
                                                          .toString(),
                                                      maxLines: 100,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text(
                                      "An error occured! Please check your internet connection."),
                                );
                              } else {
                                return const Center(
                                  child: Text("Say hi to your new friend"),
                                );
                              }
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: textField(context: context),
                      ),
                      sendButton(),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textField({required BuildContext context}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TextField(
          controller: messageController,
          style: Theme.of(context)
              .textTheme
              .subtitle1
              ?.copyWith(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Message',
              hintStyle: Theme.of(context).textTheme.caption,
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 0, color: Colors.grey),
                  borderRadius: BorderRadius.circular(25)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 0, color: Colors.grey),
                  borderRadius: BorderRadius.circular(25)),
              prefixIcon: attachmentButton(context: context),
              //suffixIcon: micButton(),
              contentPadding: const EdgeInsets.only(top: 2)),
        ),
      );

  Widget attachmentButton({required BuildContext context}) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed: () {},
        color: Colors.black,
        icon: const Icon(Icons.attach_file, size: 18),
        splashRadius: 20,
      ),
    );
  }

  Widget sendButton() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFBAD33),
            Color(0xFFF2653A),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            sendMessage();
          }),
    );
  }
}
