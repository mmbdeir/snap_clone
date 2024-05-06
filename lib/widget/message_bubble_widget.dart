import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageBubbleWidget extends StatelessWidget {
  MessageBubbleWidget({super.key, required this.text, required this.personId});

  final String text;
  final String personId;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          VerticalDivider(
            color: personId == user!.uid ? Colors.red[600] : Colors.blue,
            thickness: 4,
          ),
          Container(
            padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class NextMessageBubbleWidget extends StatelessWidget {
  NextMessageBubbleWidget(
      {super.key, required this.text, required this.personId});

  final String text;
  final String personId;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final personNameFuture =
        FirebaseFirestore.instance.collection('users').doc(personId).get();
    return FutureBuilder<DocumentSnapshot>(
        future: personNameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final personName = snapshot.data!.get('username') as String;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 4),
                child: Text(
                  personId == user!.uid ? "ME" : personName.toUpperCase(),
                  style: TextStyle(
                    color:
                        personId == user!.uid ? Colors.red[600] : Colors.blue,
                  ),
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    VerticalDivider(
                      color:
                          personId == user!.uid ? Colors.red[600] : Colors.blue,
                      thickness: 4,
                    ),
                    Text(text, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class ImageBubbleWidget extends StatelessWidget {
  ImageBubbleWidget({super.key, required this.url, required this.personId});

  final String url;
  final String personId;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          VerticalDivider(
            color: personId == user!.uid ? Colors.red[600] : Colors.blue,
            thickness: 4,
          ),
          Container(
            padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            child: Image.network(url),
          ),
        ],
      ),
    );
  }
}

class NextImageBubbleWidget extends StatelessWidget {
  NextImageBubbleWidget({super.key, required this.url, required this.personId});

  final String url;
  final String personId;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final personNameFuture =
        FirebaseFirestore.instance.collection('users').doc(personId).get();
    return FutureBuilder<DocumentSnapshot>(
        future: personNameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final personName = snapshot.data!.get('username') as String;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 4),
                child: Text(
                  personId == user!.uid ? "ME" : personName.toUpperCase(),
                  style: TextStyle(
                    color:
                        personId == user!.uid ? Colors.red[600] : Colors.blue,
                  ),
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    VerticalDivider(
                      color:
                          personId == user!.uid ? Colors.red[600] : Colors.blue,
                      thickness: 4,
                    ),
                    Image.network(url),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
