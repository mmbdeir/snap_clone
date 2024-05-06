import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:snap_clone/widget/message_bubble_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.personId});

  final personId;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userData;
  String? chatRoomId;
  File? _pickImageFile;

  @override
  void initState() {
    super.initState();
    var personId = widget.personId;
    var users = [user!.uid, personId];
    users.sort();
    chatRoomId = users.join('_');

    FirebaseFirestore.instance
        .collection('users')
        .doc(personId)
        .get()
        .then((snapshot) {
      setState(() {
        userData = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 75,
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 43),
                      alignment: Alignment.center,
                      child: Text(userData?['username'] ?? '',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            thickness: 1,
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(chatRoomId ?? '')
                  .orderBy("createdAt")
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else if (snapshots.hasError) {
                  return Center(
                    child: Text("${snapshots.error}"),
                  );
                } else {
                  final loadedMessages = snapshots.data!.docs;

                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        bottom: 40,
                        left: 7,
                        right: 7,
                      ),
                      itemCount: loadedMessages.length,
                      itemBuilder: (ctx, index) {
                        final chatMessage = loadedMessages[index].data();
                        if (chatMessage.containsKey("imageUrl")) {
                          // Check if "imageUrl" key exists
                          if (index == 0) {
                            return NextImageBubbleWidget(
                              url: chatMessage["imageUrl"],
                              personId: chatMessage["sender"],
                            );
                          } else if (loadedMessages[index - 1]["sender"] ==
                              chatMessage["sender"]) {
                            return ImageBubbleWidget(
                              url: chatMessage["imageUrl"],
                              personId: chatMessage["sender"],
                            );
                          } else {
                            return NextImageBubbleWidget(
                              url: chatMessage["imageUrl"],
                              personId: chatMessage["sender"],
                            );
                          }
                        } else if (chatMessage.containsKey("text")) {
                          // Check if "text" key exists
                          if (index == 0) {
                            return NextMessageBubbleWidget(
                              text: chatMessage["text"],
                              personId: chatMessage["sender"],
                            );
                          } else if (loadedMessages[index - 1]["sender"] ==
                              chatMessage["sender"]) {
                            return MessageBubbleWidget(
                              text: chatMessage["text"],
                              personId: chatMessage["sender"],
                            );
                          } else {
                            return NextMessageBubbleWidget(
                              text: chatMessage["text"],
                              personId: chatMessage["sender"],
                            );
                          }
                        }
                      },
                    ),
                  );
                }
              }),
          Container(
            color: Colors.grey[50],
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 10, left: 7, right: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: Colors.grey[200],
                  ),
                  width: 50,
                  height: 50,
                  child: IconButton(
                    onPressed: () {
                      _pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt, size: 30),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: Colors.grey[200],
                  ),
                  width: 230,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Chat',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.grey[600])),
                      style: const TextStyle(height: 1.4),
                      cursorColor: Colors.pinkAccent,
                      controller: _controller,
                      onSubmitted: (text) {
                        sendMessage(text);
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: Colors.grey[200],
                  ),
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      sendMessage(_controller.text); //conect the text
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: Colors.grey[200],
                  ),
                  width: 50,
                  height: 50,
                  child: IconButton(
                    onPressed: () {
                      _pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo_album, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage(type) async {
    final pickedImage =
        await ImagePicker().pickImage(source: type, maxHeight: 150);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickImageFile = File(pickedImage.path);
    });

    // Generate UUID for the image
    var uuid = Uuid().v4();

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(chatRoomId ?? '')
        .child(
            '${user!.uid}_$uuid.jpg'); // Include the UUID in the image file name

    // Upload image to Firebase Storage
    await storageRef.putFile(_pickImageFile!);

    // Get the download URL for the image
    String imageUrl = await storageRef.getDownloadURL();

    // Save image details to Firestore
    FirebaseFirestore.instance.collection(chatRoomId ?? '').doc().set({
      "createdAt": DateTime.now().toString(),
      "sender": user!.uid,
      "imageId": uuid, // Save only the UUID, not the full path
      "imageUrl": imageUrl, // Save the download URL of the image
    });
  }

  void sendMessage(String text) async {
    // final userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (text.trim().isEmpty || text.trim() == '') {
      return;
    }

    // FirebaseFirestore.instance.collection('Messages: ${user!.uid}').doc(widget.personId)
    FirebaseFirestore.instance.collection(chatRoomId ?? '').doc().set({
      "createdAt": DateTime.now().toString(),
      "sender": user!.uid,
      "text": text,
    });

    _controller.clear();
  }
}
