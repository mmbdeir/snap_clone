import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snap_clone/widget/chat_widget.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('friends')
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator.adaptive();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              var friends = snapshot.data!.data();
              if (friends == null || friends.isEmpty) {
                return const Center(
                  child: Text('No Friends'),
                );
              }
              List<String> list = [];
              for (var friend in friends.keys) {
                list.add(friend);
              }
              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return ChatWidget(personId: list[index]);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
