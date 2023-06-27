import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool isDark = false;
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
          SwitchListTile(
            value: isDark,
            onChanged: (value) {
              setState(() {
                isDark = value;
              });
            },
            title: Text("Dark Mode"),
            secondary: Icon(Icons.light_mode_outlined),
          ),
        ],
      ),
    );
  }
}
