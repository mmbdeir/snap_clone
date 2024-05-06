import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FriendRequestWidget extends StatefulWidget {
  const FriendRequestWidget({super.key, required this.person});

  final dynamic person;

  @override
  State<FriendRequestWidget> createState() => _FriendRequestWidgetState();
}

class _FriendRequestWidgetState extends State<FriendRequestWidget> {
  String? chatRoomId;
  bool isRequesting = false;
  bool isFriend = false;
  late User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    var personId = widget.person['username'];
    var users = [user!.uid, personId];
    users.sort();
    chatRoomId = users.join('_');
    checkFriendship();
    checkRequest();
  }

  Future<void> checkFriendship() async {
    final friendDocument = await FirebaseFirestore.instance
        .collection('friends')
        .doc(user!.uid)
        .get();

    final friendData = friendDocument.data();
    setState(() {
      if (friendData != null &&
          friendData.containsKey(widget.person['user_id'])) {
        isFriend = true;
      } else {
        isFriend = false;
      }
    });
  }

  Future<void> checkRequest() async {
    final requestDocument = await FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(user!.uid)
        .collection('sentRequests')
        .doc(widget.person['user_id'])
        .get();

    final requestData = requestDocument.data();
    setState(() {
      if (requestData != null &&
          requestData.containsValue(widget.person['user_id'])) {
        isRequesting = true;
      } else {
        isRequesting = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = widget.person['display_name'] ?? "No Name";
    final String userName = widget.person['username'] ?? "No Name";

    // void _loadProfileImage() async {
    //   try {
    //     final imageUrl = await FirebaseStorage.instance
    //         .ref()
    //         .child('user_images')
    //         .child('dflImptWWyPB8s3xfVXNoNruyIu2.jpg')
    //         .getDownloadURL();

    //     setState(() {
    //       _imageUrl = imageUrl;
    //     });
    //   } catch (error) {
    //   }
    // }

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 7, bottom: 2.5),
      color: Colors.white,
      child: FutureBuilder(
          future: FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child(
                  '${widget.person?['user_id']}.jpg') // Null check for 'user_id'
              .getDownloadURL()
              .catchError((_) => FirebaseStorage.instance
                  .ref()
                  .child('user_images')
                  .child('download (1).png')
                  .getDownloadURL()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 68,
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(snapshot.data!),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    userName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w100),
                  ),
                ],
              ),
              trailing: Container(
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey[300],
                ),
                child: IconButton(
                  color: Colors.black,
                  onPressed: sendFriendRequest,
                  icon: isRequesting
                      ? const Icon(
                          Icons.access_alarm,
                          color: Colors.green,
                        )
                      : !isFriend
                          ? const Icon(Icons.person_add)
                          : const Icon(
                              Icons.person_remove,
                              color: Colors.red,
                            ),
                  // icon: !isFriend ? const Icon(Icons.person_add) : const Icon(Icons.person_remove, color: Colors.red,)
                ),
              ),
            );
          }),
    );
  }

  // void addRemoveUser() async {
  //   final friendDocument = await FirebaseFirestore.instance.collection('friends').doc(user!.uid).get();
  //   final friendData = friendDocument.data();

  //   if (friendData != null && friendData.containsKey(widget.person['user_id'])) {
  //     await FirebaseFirestore.instance.collection('friends').doc(user!.uid).update({
  //       widget.person['user_id']: FieldValue.delete(),
  //     });
  //     await FirebaseFirestore.instance.collection('friends').doc(widget.person['user_id']).update({
  //       user!.uid: FieldValue.delete(),
  //     });
  //     setState(() {
  //       isFriend = false;
  //     });
  //   }
  //   else {
  //     await FirebaseFirestore.instance.collection('friends').doc(user!.uid).set({
  //       widget.person['user_id'] ?? "no id": true,
  //     }, SetOptions(merge: true));
  //     await FirebaseFirestore.instance.collection('friends').doc( widget.person['user_id']).set({
  //       user!.uid : true,
  //     }, SetOptions(merge: true));
  //     setState(() {
  //       isFriend = true;
  //     });
  //   }
  // }

  void sendFriendRequest() async {
    final data = await FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(user!.uid)
        .collection('sentRequests')
        .doc(widget.person['user_id'])
        .get();
    final friendData = data.data();
    if (friendData == null) {
      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(user!.uid)
          .collection('sentRequests')
          .doc(widget.person['user_id'])
          .set({
        'senderId': user!.uid,
        'receiverId': widget.person['user_id'],
        'status': 'pending'
      });

      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(widget.person['user_id'])
          .collection('receivedRequests')
          .doc(user!.uid)
          .set({
        'senderId': user!.uid,
        'receiverId': widget.person['user_id'],
        'status': 'pending'
      });
      setState(() {
        isRequesting = true;
      });
    } else {
      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(user!.uid)
          .collection('sentRequests')
          .doc(widget.person['user_id'])
          .delete();

      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(widget.person['user_id'])
          .collection('receivedRequests')
          .doc(user!.uid)
          .delete();
      setState(() {
        isRequesting = false;
      });
    }
  }
}
