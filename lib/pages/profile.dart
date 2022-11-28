import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/modals/userModel.dart';
import 'package:firebase_chat/pages/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ProfilePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickFile = await ImagePicker().pickImage(source: source);
    if (pickFile != null) {
      cropImage(pickFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? cropImage = await ImageCropper().cropImage(
      sourcePath: file.path,
    );

    if (cropImage != null) {
      setState(() {
        imageFile = File(cropImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("UpLoad Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                trailing: const Icon(Icons.photo_album),
                title: const Text('Select Image For Gallery'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                trailing: const Icon(Icons.camera_alt_rounded),
                title: const Text('Take a photo'),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkValues() {
    String fullName = fullNameController.text.trim();

    if (fullName == "" || imageFile == null) {
      var snackBar = SnackBar(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Text('Please Enter All Fields@!'),
        margin: const EdgeInsets.only(left: 10, right: 10),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      upLoadData();
      var snackBar = SnackBar(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Text('Data UpLoaded!'),
        margin: const EdgeInsets.only(left: 10, right: 10),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MyHomePage(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
            );
          },
        ),
      );
    }
  }

  void upLoadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepicuters")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullName = fullNameController.text.trim();

    widget.userModel.fullname = fullName;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      var snackBar = SnackBar(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Text('Data UpLoaded!'),
        margin: const EdgeInsets.only(left: 10, right: 10),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile Page'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: imageFile == null
                        ? NetworkImage(
                            widget.userModel.profilepic.toString())
                        : FileImage(imageFile!) as ImageProvider,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: addIconButtonView(),
                  )
                ],
              ),
              const SizedBox(height: 30),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  checkValues();
                },
                child: const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget addIconButtonView() => Container(
        height: 40,
        width: 40,
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
        child: IconButton(
          splashRadius: 20,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            icon: const Icon(
              Icons.camera_alt,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () {
              showPhotoOptions();
            }),
      );
}
