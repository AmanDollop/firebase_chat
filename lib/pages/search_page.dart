import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/main.dart';
import 'package:firebase_chat/modals/userModel.dart';
import 'package:firebase_chat/pages/chat_room_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../modals/chat_room_modal.dart';
import 'login.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created!");
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.2),
      body: Stack(
        children: [
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                children: [
                  SizedBox(height: 140),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .where("email", isEqualTo: searchController.text)
                          .where("email", isNotEqualTo: widget.userModel.email)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;

                            if (dataSnapshot.docs.length > 0) {
                              Map<String, dynamic> userMap =
                                  dataSnapshot.docs[0].data()
                                      as Map<String, dynamic>;

                              UserModel searchedUser =
                                  UserModel.fromMap(userMap);

                              return ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                tileColor: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.5),
                                onTap: () async {
                                  ChatRoomModel? chatroomModel =
                                      await getChatroomModel(searchedUser);

                                  if (chatroomModel != null) {
                                    Navigator.pop(context);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        targetUser: searchedUser,
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser,
                                        chatroom: chatroomModel,
                                      );
                                    }));
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(searchedUser.profilepic!),
                                  backgroundColor: Colors.grey[500],
                                ),
                                title: Text(
                                  searchedUser.fullname!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  searchedUser.email!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: const Icon(Icons.keyboard_arrow_right,
                                    color: Colors.white),
                              );
                            } else {
                              return const Text("No results found!");
                            }
                          } else if (snapshot.hasError) {
                            return const Text("An error occured!");
                          } else {
                            return const Text("No results found!");
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      }),
                ],
              ),
            ),
          ),
          myCustomContainer(context: context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          // ignore: use_build_context_synchronously
          Navigator.popUntil(context, (route) => route.isFirst);
          //Navigator.popUntil(context, (route) => route.isCurrent);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              return const LoginPage();
            }),
          );
        },
        child: const Icon(Icons.logout),
      ),

    );
  }

  Widget myCustomContainer(
      {bool isSearchActive = true,
      bool isClicked = true,
      bool isSearch = true,
      required BuildContext context}) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
          height: 170,
          child: Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          appLogo(),
                          const SizedBox(width: 10),
                          userWelcomeText(context: context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
              searchTextField(context: context),
              const Expanded(
                child: SizedBox.shrink(),
              ),
              appBarDash(context: context)
            ],
          ),
        ),
      ),
    );
  }

  Widget appBarDash({
    required BuildContext context,
  }) {
    return Container(
      width: 200,
      height: 2,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: commonLinearGradientView(context: context)),
    );
  }

  Widget gradientsText({
    required Widget text,
    required Gradient gradient,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: text,
    );
  }

  Widget userWelcomeText({
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jay Gupta",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(color: Colors.white),
        ),
        Text(
          "Welcome Back!",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget appLogo() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
            image: NetworkImage(
                "https://cdn4.vectorstock.com/i/1000x1000/98/03/chat-app-icon-template-mobile-application-icon-vector-20839803.jpg"),
            fit: BoxFit.fill),
      ),
    );
  }

  Widget searchTextField({required BuildContext context}) {
    return Padding(
        padding: const EdgeInsets.only(left: 21, right: 22),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: Theme.of(context).brightness == Brightness.light
                ? commonLinearGradientView(context: context)
                : const LinearGradient(colors: [
                    Color(0xFFFBAD33),
                    Color(0xFFF2653A),
                  ]),
          ),
          child: Container(
            height: 36,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: TextFormField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (value) {
                      setState(() {});
                      },
                    autofocus: true,
                    cursorColor: Theme.of(context).primaryColor,
                    maxLines: 1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                          left: 0, bottom: 0, top: 0, right: 0),
                      hintText: "Search",
                      hintStyle: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(fontSize: 10),
                      prefixIcon: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => clickBackIcon(context: context),
                          splashRadius: 20,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: VerticalDivider(
                      thickness: 1,
                      color: Colors.grey,
                      indent: 9,
                      endIndent: 9),
                ),
              ],
            ),
          ),
        ));
  }

  clickBackIcon({required BuildContext context}) {
    Navigator.pop(context);
  }

  static LinearGradient commonLinearGradientView(
          {required BuildContext context}) =>
      const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFBAD33),
          Color(0xFFF2653A),
        ],
      );
}
