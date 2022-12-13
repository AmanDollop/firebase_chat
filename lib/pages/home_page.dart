import 'dart:ui';
import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/modals/chat_room_modal.dart';
import 'package:firebase_chat/modals/firebase_helper.dart';
import 'package:firebase_chat/modals/userModel.dart';
import 'package:firebase_chat/pages/chat_room_page.dart';
import 'package:firebase_chat/pages/profile.dart';
import 'package:firebase_chat/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
      bottomNavigationBar: SizedBox(
        height: 80,
        child: AnimatedButtonBar(
          borderColor: Colors.tealAccent,
          borderWidth: 2,
          backgroundColor: Colors.grey,
          foregroundColor: Colors.tealAccent,
          radius: 8.0,
          padding: const EdgeInsets.all(16.0),
          animationDuration: const Duration(seconds: 1),
          invertedSelection: true,
          children: [
            ButtonBarEntry(
                onTap: () => print('Home item tapped'),
                child: const Text('Home')),
            ButtonBarEntry(
                onTap: () => print('Chat item tapped'),
                child: const Text('Chat'))
          ],
        ),
      ),
      backgroundColor: Colors.black.withOpacity(.2),
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
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
                                        horizontal: 10, vertical: 5),
                                    child: InkWell(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Column(
                                                children: [
                                                  const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 70,
                                                        width: 70,
                                                        decoration:
                                                            BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                          image: NetworkImage(
                                                              targetUser
                                                                  .profilepic
                                                                  .toString()),
                                                        )),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        targetUser.fullname
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "chatrooms")
                                                            .doc(chatRoomModel
                                                                .chatroomid)
                                                            .delete();
                                                      },
                                                      child:
                                                          const Text("Delete"),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            side: const BorderSide(
                                                width: 2,
                                                color: Colors.tealAccent)),
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
                                        leading: InkWell(
                                          onTap: () {
                                            showDialog(
                                              builder: (context) => AlertDialog(
                                                title: Image(
                                                  image: NetworkImage(
                                                    targetUser.profilepic
                                                        .toString(),
                                                  ),
                                                ),
                                              ),
                                              useRootNavigator: false,
                                              context: context,
                                            );
                                          },
                                          child: SizedBox(
                                            height: 55,
                                            width: 55,
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  targetUser.profilepic
                                                      .toString()),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          targetUser.fullname.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            (chatRoomModel.lastMessage
                                                        .toString() !=
                                                    "")
                                                ? Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      chatRoomModel.lastMessage
                                                          .toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )
                                                : const Text(
                                                    "Say hi to your new friend!",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                children: [
                                                  (chatRoomModel.lastMessage
                                                              .toString() !=
                                                          "")
                                                      ? Text(
                                                          chatRoomModel
                                                              .dateTime!.hour
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        )
                                                      : const Text(
                                                          "",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                  (chatRoomModel.lastMessage
                                                              .toString() !=
                                                          "")
                                                      ? Text(
                                                          ":${chatRoomModel.dateTime!.minute}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        )
                                                      : const Text(
                                                          "",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                  (chatRoomModel.lastMessage
                                                              .toString() !=
                                                          "")
                                                      ? Text(
                                                          ":${chatRoomModel.dateTime!.second}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        )
                                                      : const Text(
                                                          "",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
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
      {required BuildContext context, UserModel? userModel}) {
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
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ProfilePage(
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser);
                                    },
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    widget.userModel.profilepic.toString()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          userWelcomeText(context: context),
                        ],
                      ),
                    ),
                    appLogo(),
                  ],
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
              searchTextFieldButton(
                context: context,
              ),
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
          widget.userModel.fullname.toString(),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Text(
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
      ),
      child: LottieBuilder.network(
          'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
          repeat: true),
    );
  }

  Widget searchTextFieldButton({
    required BuildContext context,
  }) {
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
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
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
