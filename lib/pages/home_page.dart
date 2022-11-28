import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/modals/chat_room_modal.dart';
import 'package:firebase_chat/modals/firebase_helper.dart';
import 'package:firebase_chat/modals/userModel.dart';
import 'package:firebase_chat/pages/chat_room_page.dart';
import 'package:firebase_chat/pages/search_page.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyHomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.2),
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel.uid}",
                    isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 140),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          Map<String, dynamic> participants =
                              chatRoomModel.participants!;
                          List<String> participantKeys =
                              participants.keys.toList();
                          participantKeys.remove(widget.userModel.uid);

                          return FutureBuilder(
                            future: FireBaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserModel targetUser =
                                      userData.data as UserModel;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10,vertical: 5),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                      tileColor: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.5),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) {
                                            return ChatRoomPage(
                                              chatroom: chatRoomModel,
                                              firebaseUser:
                                                  widget.firebaseUser,
                                              userModel: widget.userModel,
                                              targetUser: targetUser,
                                            );
                                          }),
                                        );
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            targetUser.profilepic.toString()),
                                      ),
                                      title: Text(
                                        targetUser.fullname.toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      subtitle: (chatRoomModel.lastMessage
                                                  .toString() !=
                                              "")
                                          ? Text(
                                              chatRoomModel.lastMessage
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )
                                          : const Text(
                                              "Say hi to your new friend!",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No Chats",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 3,
                  ),
                );
              }
            },
          ),
          myCustomContainer(context: context),
        ],
      ),
    );
  }

  Widget myCustomContainer(
      {bool isSearchActive = false,
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
              searchTextFieldButton(context: context, isSearch: isSearch),
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
      children: const [
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
        image: const DecorationImage(
            image: NetworkImage(
                "https://cdn4.vectorstock.com/i/1000x1000/98/03/chat-app-icon-template-mobile-application-icon-vector-20839803.jpg"),
            fit: BoxFit.fill),
      ),
    );
  }

  Widget searchTextFieldButton(
      {required BuildContext context, required bool isSearch}) {
    return Padding(
      padding: const EdgeInsets.only(left: 21, right: 22),
      child: Theme.of(context).brightness == Brightness.light
          ? Container(
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: commonLinearGradientView(context: context),
              ),
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return SearchPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser);
                  })),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    maximumSize: const Size(300, 50),
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.all(3.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 9,
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 2,
                              child: Icon(Icons.search,
                                  color: Colors.grey, size: 18),
                            ),
                            Expanded(
                              flex: 7,
                              child: Text(
                                "Search",
                                style: TextStyle(color: Colors.grey,fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: VerticalDivider(
                            thickness: 1,
                            color: Colors.grey,
                            indent: 6,
                            endIndent: 6),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed:
                    () /*=> Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchItemView(isSearch: isSearch,),
            ),
          ),*/
                    {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  maximumSize: const Size(300, 50),
                  foregroundColor: Colors.grey,
                  backgroundColor: Colors.blue,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.all(3.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Icon(Icons.search,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ),
                          Expanded(
                            flex: 7,
                            child: Text(
                              "Search",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: VerticalDivider(
                          thickness: 1,
                          color: Colors.grey,
                          indent: 6,
                          endIndent: 6),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              "Category",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(fontSize: 10),
                            ),
                          ),
                          const Expanded(
                            flex: 4,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
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
