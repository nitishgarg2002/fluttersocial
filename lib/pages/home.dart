import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/models/user.dart';
import 'package:flutter_social/pages/activity_feed.dart';
import 'package:flutter_social/pages/create_account.dart';
import 'package:flutter_social/pages/profile.dart';
import 'package:flutter_social/pages/search.dart';

import 'package:flutter_social/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in:$err');
    });
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in:$err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
     createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }
  createUserInFirestore() async{
  final GoogleSignInAccount user = googleSignIn.currentUser;
   DocumentSnapshot doc = await usersRef.doc(user.id).get();
  if (!doc.exists) {
  final username = await Navigator.push(context, 
    MaterialPageRoute(
      builder: (context) => CreateAccount()
    ));
    usersRef.doc(user.id).set({
      'id':user.id,
      'username':username,
      'photoUrl':user.photoUrl,
      'email': user.email,
      'displayName':user.displayName,
      'bio':'',
      'timestamp': timestamp,
    });
    doc = await usersRef.doc(user.id).get();
  }
   currentUser = User.fromDocument(doc);
   print(currentUser);
   print(currentUser.username);
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          RaisedButton(
            child: Text('Logout'),
            onPressed: logout,
          ),
         // Timeline(),
          Search(),
          Upload(),
          ActivityFeed(),
          Profile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 35,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white10])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Flutter Social',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 70,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
