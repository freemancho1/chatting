import 'package:chatting/config/palette.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'chat.dart';

Logger logger = Logger(printer: PrettyPrinter(methodCount: 0));

class LoginSignupScreen extends StatefulWidget {
    const LoginSignupScreen({super.key});

    @override
    State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
    bool isSignup = true;
    final _authentication = FirebaseAuth.instance;
    final _formKey = GlobalKey<FormState>();

    String userName = '';
    String userEmail = '';
    String userPassword = '';
    
    bool _showSpinner = false;

    void _tryValidation() {
        final formState = _formKey.currentState!;
        if (formState.validate()) formState.save();
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.backgroundColor,
        body: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            child: GestureDetector(
                // 바탕화면을 클릭했을 때, 입력 키보드를 아래로 내림.
                onTap: () => FocusScope.of(context).unfocus(),
                child: Stack(
                    children: [
                        _loginImageContainer(),
                        _loginAlertContainer(),
                        _submitContainer(),
                        _otherAccountContainer(),
                    ],
                ),
            ),
        ),
    );

    Widget _loginImageContainer() => Positioned(
        top: 0, left: 0, right: 0,
        child: Container(
            height: 320,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/gate.png'),
                    fit: BoxFit.fill
                )
            ),
            child: Container(
                padding: const EdgeInsets.only(top: 80, left: 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        RichText(
                            text: TextSpan(
                                text: 'Welcome',
                                style: const TextStyle(
                                    letterSpacing: 0.9,
                                    fontSize: 24,
                                    color: Colors.white
                                ),
                                children: [
                                    TextSpan(
                                        text: isSignup
                                            ? ' to Freeman chat!'
                                            : ' back',
                                        style: const TextStyle(
                                            letterSpacing: 0.9,
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        )
                                    )
                                ]
                            )
                        ),
                        const SizedBox(height: 8,),
                        Text(
                            'Sign${isSignup ? "up": "in"} to continue!',
                            style: const TextStyle(
                                letterSpacing: 0.9,
                                color: Colors.white,
                            ),
                        )
                    ],
                ),
            )
        )
    );

    Widget _loginAlertContainer() => AnimatedPositioned(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
        top: 180,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            padding: const EdgeInsets.all(20),
            height: isSignup ? 290: 250,
            width: MediaQuery.of(context).size.width - 40,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                    )
                ]
            ),
            child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                __loginSignupGesture('LOGIN', !isSignup),
                                __loginSignupGesture('SIGNUP', isSignup)
                            ],
                        ),
                        (isSignup) ? __signupFormContainer() : __loginFormContainer(),
                    ],
                ),
            ),
        ),
    );

    Widget __loginSignupGesture(String title, bool condition) {
        // logger.d('title: $title');

        return GestureDetector(
            onTap: () => setState(() => isSignup = (title=='LOGIN' ? false: true)),
            child: Column(
                children: [
                    Text(
                        title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: condition
                                ? Palette.activeColor
                                : Palette.textColor1
                        ),
                    ),
                    if (condition)
                        Container(
                            margin: const EdgeInsets.only(top: 3),
                            width: 55, height: 2,
                            color: Colors.orange,
                        )
                ],
            ),
        );
    }

    Widget __signupFormContainer() => Container(
        margin: const EdgeInsets.only(top: 20),
        child: Form(
            key: _formKey,
            child: Column(
                children: [
                    TextFormField(
                        key: const ValueKey(1),
                        validator: ___nameValidator,
                        onSaved: (value) => userName = value!,
                        onChanged: (value) => userName = value,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                                Icons.account_circle,
                                color: Palette.iconColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                                borderRadius: BorderRadius.all(Radius.circular(35))
                            ),
                            hintText: 'User name',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Palette.textColor1
                            ),
                            contentPadding: EdgeInsets.all(10)
                        ),
                        textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8,),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        key: const ValueKey(2),
                        validator: ___emailValidator,
                        onSaved: (value) => userEmail = value!,
                        onChanged: (value) => userEmail = value,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                                Icons.email,
                                color: Palette.iconColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                                borderRadius: BorderRadius.all(Radius.circular(35))
                            ),
                            hintText: 'User name',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Palette.textColor1
                            ),
                            contentPadding: EdgeInsets.all(10)
                        ),
                        textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8,),
                    TextFormField(
                        obscureText: true,
                        key: const ValueKey(3),
                        validator: ___passwordValidator,
                        onSaved: (value) => userPassword = value!,
                        onChanged: (value) => userPassword = value,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                                Icons.lock,
                                color: Palette.iconColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                                borderRadius: BorderRadius.all(Radius.circular(35))
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Palette.textColor1
                            ),
                            contentPadding: EdgeInsets.all(10)
                        ),
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (_) {
                            __goLogin();
                        },
                    )
                ],
            ),
        ),
    );

    Widget __loginFormContainer() => Container(
        margin: const EdgeInsets.only(top: 20),
        child: Form(
            key: _formKey,
            child: Column(
                children: [
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        key: const ValueKey(4),
                        validator: ___emailValidator,
                        onSaved: (value) => userEmail = value!,
                        onChanged: (value) => userEmail = value,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                                Icons.email,
                                color: Palette.iconColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                                borderRadius: BorderRadius.all(Radius.circular(35))
                            ),
                            hintText: 'User name',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Palette.textColor1
                            ),
                            contentPadding: EdgeInsets.all(10)
                        ),
                        textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8,),
                    TextFormField(
                        obscureText: true,
                        key: const ValueKey(5),
                        validator: ___passwordValidator,
                        onSaved: (value) => userPassword = value!,
                        onChanged: (value) => userPassword = value,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                                Icons.lock,
                                color: Palette.iconColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Palette.textColor1),
                                borderRadius: BorderRadius.all(Radius.circular(35))
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Palette.textColor1
                            ),
                            contentPadding: EdgeInsets.all(10)
                        ),
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (_) {
                            __goLogin();
                        },
                    )
                ],
            ),
        ),
    );

    String? ___nameValidator(String? value) =>
        (value!.isEmpty || value.length < 4)
            ? 'Please enter at least 4 characters' : null;

    String? ___emailValidator(String? value) =>
        (value!.isEmpty || !value.contains('@'))
            ? 'Please enter a valid email address' : null;

    String? ___passwordValidator(String? value) {
        return (value!.isEmpty || value.length < 6)
            ? 'Password must be at least 7 characters long.' : null;
    }

    Widget _submitContainer() => AnimatedPositioned(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
        top: isSignup ? 430: 390,
        right: 0, left: 0,
        child: Center(
            child: Container(
                padding: const EdgeInsets.all(15),
                width: 90, height: 90,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                ),
                child: GestureDetector(
                    onTap: __goLogin,
                    child: Container(
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Colors.orange, Colors.red],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(.3),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1)
                                )
                            ]
                        ),
                        child: const Icon(
                            Icons.arrow_forward, color: Colors.white,
                        ),
                    ),
                ),
            ),
        ),
    );

    void __goLogin() async {
        setState(() {
            _showSpinner = true;
        });
        _tryValidation();
        if (isSignup) {
            try {
                final newUser = await _authentication
                    .createUserWithEmailAndPassword(
                    email: userEmail,
                    password: userPassword
                );
                if (newUser.user != null) {
                    /// 컬렉션('user')이 없는 경우, 자동 생성된다.
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(newUser.user!.uid)
                        .set({
                        'name': userName,
                        'email': userEmail
                    });
                    // __goChatFromLogin();
                }
                setState(() => _showSpinner = false);
            } catch(e) {
                debugPrint('Error!!\n${e.toString()}');
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please check your email or password.'
                        ),
                        backgroundColor: Colors.deepOrange,
                    )
                );
                setState(() {
                    _showSpinner = false;
                });
            }
        } else {
            try {
                final currUser = await _authentication
                    .signInWithEmailAndPassword(
                    email: userEmail,
                    password: userPassword
                );
                if (currUser.user != null) {
                    // __goChatFromLogin();
                }
                setState(() => _showSpinner = false);
            } catch(e) {
                debugPrint('Error!!\n${e.toString()}');
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please check your email or password.'
                        ),
                        backgroundColor: Colors.deepOrange,
                    )
                );
                setState(() {
                    _showSpinner = false;
                });
            }
        }
    }

    void __goChatFromLogin() {
        setState(() => _showSpinner = false);
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => const Chat()));
    }

    Widget _otherAccountContainer() => Positioned(
        // duration: const Duration(milliseconds: 500),
        // curve: Curves.easeIn,
        // top: isSignup
        //     ? MediaQuery.of(context).size.height - 125
        //     : MediaQuery.of(context).size.height - 165,
        top: MediaQuery.of(context).size.height - 125,
        // bottom: 50,
        left: 0, right: 0,
        child: Column(
            children: [
                Text(isSignup ? 'or Signup with' : 'or Signin with'),
                const SizedBox(height: 10,),
                TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Google'),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Palette.googleColor,
                        minimumSize: const Size(155, 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        )
                    ),
                )
            ],
        ),
    );
}
