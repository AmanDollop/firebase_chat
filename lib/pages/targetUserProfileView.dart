import 'package:firebase_chat/modals/userModel.dart';
import 'package:flutter/material.dart';

class TargetUserProfileView extends StatefulWidget {
  final UserModel targetUser;

  const TargetUserProfileView({Key? key, required this.targetUser})
      : super(key: key);

  @override
  State<TargetUserProfileView> createState() => _TargetUserProfileViewState();
}

class _TargetUserProfileViewState extends State<TargetUserProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.2),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 36),
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
                const SizedBox(width: 16),
                Text(
                  widget.targetUser.fullname.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFBAD33),
                    Color(0xFFF2653A),
                  ],
                ),
                border: const Border(
                    bottom: BorderSide(color: Colors.tealAccent, width: 3),
                    left: BorderSide(color: Colors.tealAccent, width: 3),
                    top: BorderSide(color: Colors.tealAccent, width: 3),
                    right: BorderSide(color: Colors.tealAccent, width: 3)),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.targetUser.profilepic.toString(),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Email : ${widget.targetUser.email}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
