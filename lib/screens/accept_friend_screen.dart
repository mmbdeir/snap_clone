import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap_clone/widget/accept_friend_widget.dart';

class AcceptFriendScreen extends StatefulWidget {
  const AcceptFriendScreen({super.key});

  @override
  State<AcceptFriendScreen> createState() => _AcceptFriendScreenState();
}

class _AcceptFriendScreenState extends State<AcceptFriendScreen> {
  late User? user;
  late Stream<QuerySnapshot> stream;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    stream = FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(user!.uid)
        .collection('receivedRequests')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          color: Colors.grey[200],
        ),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: stream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var length = snapshot.data!.docs.length;
                    return ListView.builder(
                      itemCount: length,
                      itemBuilder: (context, index) {
                        var personId = snapshot.data!.docs[index].id;
                        return AcceptFriendWidget(personId: personId);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
