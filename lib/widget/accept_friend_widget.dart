import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

User? user = FirebaseAuth.instance.currentUser;

class AcceptFriendWidget extends StatefulWidget {
  const AcceptFriendWidget({super.key, required this.personId});

  final dynamic personId;

  @override
  State<AcceptFriendWidget> createState() => _AcceptFriendWidgetState();
}

class _AcceptFriendWidgetState extends State<AcceptFriendWidget> {
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 7, bottom: 2.5),
      color: Colors.white,
      child: FutureBuilder(
        future: FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${widget.personId}.jpg')
              .getDownloadURL()
              .catchError((_) =>
                FirebaseStorage.instance
                    .ref()
                    .child('user_images')
                    .child('default_user_image_url.jpg')
                    .getDownloadURL()
              ),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 68,
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return ListTile(
            leading: 
                CircleAvatar(
                  backgroundImage: NetworkImage(snapshot.data!),
                ),
            title: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(widget.personId).snapshots(),
              builder: (context, snapshot) {
                var personData = snapshot.data!.data();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personData!['display_name'],
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      personData['username'],
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w100
                      ),
                    ),
                  ],
                );
              } 
            ),
            trailing: Container( 
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[300],
              ),
              child: IconButton(
                color: Colors.black,
                onPressed: acceptFriendRequest,
                icon: const Icon(Icons.check, size: 30),
              ),
            ),
          );
        }
      ),
    );
  }

  void acceptFriendRequest() async {
    // Delete friend requests
    await FirebaseFirestore.instance.collection('friendRequests').doc(currentUser!.uid).collection('receivedRequests').doc(widget.personId).delete();
    await FirebaseFirestore.instance.collection('friendRequests').doc(widget.personId).collection('sentRequests').doc(currentUser!.uid).delete();

    // Add to friends list
    await FirebaseFirestore.instance.collection('friends').doc(currentUser!.uid).set({
      widget.personId: true,
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('friends').doc(widget.personId).set({
      currentUser!.uid : true,
    }, SetOptions(merge: true));
  }
}