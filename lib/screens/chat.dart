import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat extends StatefulWidget {
    const Chat({super.key});

    @override
    State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
    final _authentication = FirebaseAuth.instance;
    User? currentUser;

    void getCurrentUser() {
        try {
            final user = _authentication.currentUser;
            if (user != null) {
                currentUser = user;
                debugPrint('Current User(email): ${currentUser!.email}');
            }
        } catch(e) {
            debugPrint('getCurrentUser error:\n${e.toString()}');
        }
    }

    @override
    void initState() {
        super.initState();
        getCurrentUser();
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Chatting'),
            actions: [
                IconButton(
                    onPressed: () {
                        _authentication.signOut();
                        // Navigator.pop(context);
                    },
                    icon: const Icon(
                        Icons.exit_to_app_rounded,
                        color: Colors.white,
                    )
                ),
            ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore
                .instance
                .collection('chats/NkV2HZw6BmO7GRt3oaF3/message')
                .snapshots(),
            builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(),
                    );
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) => Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                            docs[index]['text'],
                            style: const TextStyle(fontSize: 20),
                        ),
                    ),
                );
            },
        ),
    );
}