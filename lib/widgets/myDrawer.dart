import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  child: Image.network(
                    "${FirebaseAuth.instance.currentUser!.photoURL}",
                    height: 50,
                    width: 50,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                Column(
                  children: [
                    Text(
                      "${FirebaseAuth.instance.currentUser!.displayName}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "${FirebaseAuth.instance.currentUser!.email}",
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("uid",
                    isEqualTo: "${FirebaseAuth.instance.currentUser!.uid}")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data != null) {
                var docId = snapshot.data!.docs[0].id;
                return ExpansionTile(
                  title: Text("Theme"),
                  leading: Icon(Icons.highlight),
                  children: [
                    RadioListTile<int>(
                      value: 0,
                      title: Text("Dark"),
                      secondary: Icon(Icons.nightlight_round_sharp),
                      groupValue: snapshot.data!.docs[0]["isDark"],
                      onChanged: (value) {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(docId)
                            .update(
                          {
                            "isDark": value,
                          },
                        );
                      },
                    ),
                    RadioListTile<int>(
                      value: 1,
                      title: Text("Light"),
                      secondary: Icon(Icons.light_mode),
                      groupValue: snapshot.data!.docs[0]["isDark"],
                      onChanged: (value) {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(docId)
                            .update(
                          {
                            "isDark": value,
                          },
                        );
                      },
                    ),
                    RadioListTile<int>(
                      value: 2,
                      title: Text("System"),
                      secondary: Icon(Icons.phone_iphone_sharp),
                      groupValue: snapshot.data!.docs[0]["isDark"],
                      onChanged: (value) {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(docId)
                            .update(
                          {
                            "isDark": value,
                          },
                        );
                      },
                    ),
                  ],
                );
              }

              return Container();
            },
          ),
        ],
      ),
    );
  }
}
