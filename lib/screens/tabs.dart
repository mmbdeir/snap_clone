import 'package:flutter/material.dart';
import 'package:snap_clone/auth_screens/choose_screen.dart';
import 'package:snap_clone/screens/request_friend_screen.dart';
import 'package:snap_clone/screens/accept_friend_screen.dart';
import 'package:snap_clone/screens/chats_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snap_clone/screens/profile_screen.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

User? signedUser = FirebaseAuth.instance.currentUser;

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;
  String? displayedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    setState(() {});
  }

  void _loadProfileImage() async {
    final User? signedUser = FirebaseAuth.instance.currentUser;

    if (signedUser == null) {
      return;
    }

    final imageUrl = await FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${signedUser.uid}.jpg')
        .getDownloadURL()
        .catchError((_) => FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('default_user_image_url.jpg')
            .getDownloadURL());

    if (mounted) {
      setState(() {
        displayedImageUrl = imageUrl;
      });
    }
  }

  void changeScreen(var screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage = const ChatsScreen();
    String _chosenModel;
    bool _showDropdown = false;
    if (_currentIndex == 1) {}

    if (_currentIndex == 1) {}

    return Expanded(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ClipRRect(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  NetworkImage(displayedImageUrl ?? '')),
                          const SizedBox(width: 10),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                color: Colors.grey[200]),
                            child: GestureDetector(
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RequestFriendScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.search),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Chat',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: const Icon(Icons.person_add),
                            ),
                            onTap: () async {
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AcceptFriendScreen()),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.grey[200],
                            ),
                            child: PopupMenuButton<String>(
                              itemBuilder: (BuildContext context) {
                                return {'Profile', 'Log Out'}
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                              onSelected: (String choice) {
                                switch (choice) {
                                  case 'Profile':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileScreen()),
                                    );
                                    break;
                                  case 'Log Out':
                                    FirebaseAuth.instance
                                        .signOut()
                                        .then((value) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseScreen()),
                                      );
                                    }).catchError((error) {
                                      print("Error signing out: $error");
                                    });
                                    break;
                                }
                              },
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () async {
                          //     await FirebaseAuth.instance.signOut();
                          //     if (mounted) {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(builder: (context) => const ChooseScreen()),
                          //       );
                          //     }
                          //   },
                          //   child: CircleAvatar(
                          //     backgroundColor: Colors.grey[200],
                          //     child: const Icon(Icons.more_horiz),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: currentPage,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add, color: Colors.white60),
              activeIcon: Icon(Icons.post_add, color: Colors.blue),
              label: 'H',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on, color: Colors.white60),
              activeIcon: Icon(Icons.location_on, color: Colors.green),
              label: 'H',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt, color: Colors.white60),
              activeIcon: Icon(Icons.camera_alt, color: Colors.yellow),
              label: 'H',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people, color: Colors.white60),
              activeIcon:
                  Icon(Icons.post_add_outlined, color: Colors.purpleAccent),
              label: 'H',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow_outlined, color: Colors.white60),
              activeIcon: Icon(Icons.post_add_outlined, color: Colors.red),
              label: 'H',
            ),
          ],
          currentIndex: _currentIndex,
        ),
      ),
    );
  }
}
