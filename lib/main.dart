import 'package:chatting/screens/chat.dart';
import 'package:chatting/screens/login_signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    runApp(const ChattingApp());
}

class ChattingApp extends StatelessWidget {
    const ChattingApp({super.key});
    static String title = 'Chatting';

    @override
    Widget build(BuildContext context) => MaterialApp(
        title: ChattingApp.title,
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
                return (snapshot.hasData) ? const Chat() : const LoginSignupScreen();
            },
        )
    );
}