import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap_clone/screens/chats_screen.dart';
import 'package:snap_clone/screens/tabs.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen(
      {super.key,
      required this.enteredEmail,
      required this.enteredPassword,
      required this.enteredUsername,
      required this.birthday,
      required this.phoneNumber,
      required this.displayName});

  final String enteredEmail;
  final String enteredPassword;
  final String enteredUsername;
  final dynamic phoneNumber;
  final DateTime? birthday;
  final String displayName;

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  late User? user;
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  void _continue() async {
    try {
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
        email: widget.enteredEmail,
        password: widget.enteredPassword,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'username': widget.enteredUsername,
        'email': widget.enteredEmail,
        'password': widget.enteredPassword,
        'phone_number': widget.phoneNumber,
        'birthday': widget.birthday ?? DateTime.now(),
        'user_id': userCredentials.user!.uid,
        'display_name': widget.displayName,
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Tabs(),
          ),
        );
      }
      //     gs://flurrer-snap-chat.appspot.com/user_images/download (1).png
      // final file = File.fromUri(
      //     'gs://flurrer-snap-chat.appspot.com/user_images/download (1).png'
      //         as Uri);

      // final storageRef = FirebaseStorage.instance
      //     .ref()
      //     .child('user_images')
      //     .child('${user!.uid}.jpg');
      // await storageRef.putFile(file);
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: ((BuildContext context) {
          return AlertDialog.adaptive(
            content: Text(
              error.message ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              textAlign: TextAlign.center,
              'Get Started',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              width: 200,
              child: Text(
                textAlign: TextAlign.center,
                'Enable app permission to make sign up easy',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.black87,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Image.asset('assets/images/snap_getstarted.png', scale: 2),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 11),
                      backgroundColor: Colors.blueAccent),
                  onPressed: _continue,
                  child: Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
