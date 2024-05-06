import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snap_clone/widget/request_friend_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestFriendScreen extends StatefulWidget {
  const RequestFriendScreen({super.key});

  @override
  State<RequestFriendScreen> createState() => _SearchFriendScreen();
}

class _SearchFriendScreen extends State<RequestFriendScreen> {
  var controller = TextEditingController();
  late Stream<QuerySnapshot> stream;
  late User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    stream = FirebaseFirestore.instance
        .collection('users')
        .orderBy('user_id')
        .where('user_id', isNotEqualTo: user!.uid)
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.only(left: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80),
                            color: Colors.grey[200],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_outlined,
                                  size: 30,
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 15, right: 5),
                                    child: TextField(
                                      keyboardType: TextInputType.name,
                                      onChanged: (value) {
                                        searchPeople(value);
                                      },
                                      cursorColor: Colors.black,
                                      decoration: const InputDecoration(
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                      ),
                                      controller: controller,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey[600],
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      controller.clear();
                                    },
                                    icon: const Icon(
                                      Icons.close_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
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
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var userData = snapshot.data!.docs[index].data();
                        var userId = snapshot.data!.docs[index].get('user_id');
                        return FutureBuilder(
                          future: FirebaseStorage.instance
                              .ref()
                              .child('user_images')
                              .child('download (1).png')
                              .getDownloadURL(),
                          builder:
                              (context, AsyncSnapshot<String> urlSnapshot) {
                            if (urlSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator.adaptive();
                            } else if (urlSnapshot.hasError) {
                              return Text(
                                  'Error: ${urlSnapshot.error}  $userId');
                            } else if (urlSnapshot.data != null) {
                              return FriendRequestWidget(
                                person: userData,
                              );
                            } else {
                              return const SizedBox(
                                child: Text("else"),
                              );
                            }
                          },
                        );
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

  // Define the search function here
  void searchPeople(String query) {
    setState(() {
      Stream<QuerySnapshot> temp = FirebaseFirestore.instance
          .collection('users')
          .orderBy('user_id')
          .where('user_id', isNotEqualTo: user!.uid)
          .startAt([query]).snapshots();
    });
  }
}
