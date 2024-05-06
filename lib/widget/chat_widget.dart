// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:snap_clone/screens/message_screen.dart';

// class ChatWidget extends StatefulWidget {
//   const ChatWidget({super.key, required this.personId});

//   final dynamic personId;

//   @override
//   State<ChatWidget> createState() => _ChatWidgetState();
// }

// class _ChatWidgetState extends State<ChatWidget> {
//   late DocumentSnapshot userData;
//   bool isLoadingProfileImage = false;
//   var defaultImage = FirebaseStorage.instance.ref().child('user_images').child('default_user_image_url.jpg').getDownloadURL();
//   String? _imageUrl;

//   @override
//   void initState() {
//     super.initState();
//     var personId = widget.personId;
//     _loadProfileImage();
//     FirebaseFirestore.instance.collection('users').doc(personId).get().then((snapshot) {
//       setState(() {
//         userData = snapshot;
//       });
//     });
//     setState(() {});
//   }

//   void _loadProfileImage() async {
//     try {
//       final imageUrl = await FirebaseStorage.instance
//           .ref()
//           .child('user_images')
//           .child('${widget.personId}.jpg')
//           .getDownloadURL();

//       setState(() {
//         _imageUrl = imageUrl;
//         isLoadingProfileImage = false;
//       });
//     } catch (error) {
//       setState(() {
//         isLoadingProfileImage = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var displayName = userData['display_name'];
//     return FutureBuilder(
//       future: FirebaseStorage.instance.ref().child('user_images').child('default_user_image_url.jpg').getDownloadURL(),
//       builder: (context, snapshot) {
//         return Column(
//           children: [
//             Container(
//               width: double.infinity,
//               margin: const EdgeInsets.only(bottom: 4, top: 4),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 60,
//                     height: 60,
//                     child: _imageUrl != null ?
//                     CircleAvatar(
//                       backgroundImage: NetworkImage(_imageUrl!),
//                     ) : CircleAvatar  (
//                       backgroundImage: NetworkImage(snapshot.data!),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Text(displayName, style: Theme.of(context).textTheme.titleLarge,),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(25)
//                     ),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (
//                               (context) => MessageScreen(personId: widget.personId,)
//                             ),
//                           ),
//                         );
//                       },
//                       child: Row(
//                         children: [
//                           const Icon(Icons.camera_alt, color: Colors.lightBlue, size: 30),
//                           const SizedBox(width: 10),
//                           Text('Snap', style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                               color: Colors.lightBlue,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10,)
//                 ],
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Divider(
//                 thickness: 1,
//               ),
//             ),
//           ],
//         );
//       }
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snap_clone/screens/message_screen.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key, required this.personId});

  final dynamic personId;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late DocumentSnapshot userData;
  bool isLoadingProfileImage = false;
  var defaultImage = FirebaseStorage.instance
      .ref()
      .child('user_images')
      .child('default_user_image_url.jpg')
      .getDownloadURL();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    var personId = widget.personId;
    _loadProfileImage();
    FirebaseFirestore.instance
        .collection('users')
        .doc(personId)
        .get()
        .then((snapshot) {
      setState(() {
        userData = snapshot;
      });
    });
    setState(() {});
  }

  void _loadProfileImage() async {
    try {
      final imageUrl = await FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${widget.personId}.jpg')
          .getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
        isLoadingProfileImage = false;
      });
    } catch (error) {
      setState(() {
        isLoadingProfileImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('download (1).png')
            .getDownloadURL(),
        builder: (context, snapshot) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 4, top: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: _imageUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(_imageUrl!),
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data!),
                            ),
                    ),
                    const SizedBox(width: 20),
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.personId)
                            .get(),
                        builder: (context, snapshot) {
                          return Text(snapshot.data!['display_name'],
                              style: Theme.of(context).textTheme.titleLarge);
                        }),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(25)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => MessageScreen(
                                    personId: widget.personId,
                                  )),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt,
                                color: Colors.lightBlue, size: 30),
                            const SizedBox(width: 10),
                            Text(
                              'Snap',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Divider(
                  thickness: 1,
                ),
              ),
            ],
          );
        });
  }
}
