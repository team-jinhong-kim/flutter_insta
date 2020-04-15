import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(); //구글 로그인을 구현하기 위해 필요한 객체
final CollectionReference usersRef = Firestore.instance
    .collection('users'); //Firestore로부터 'users' collection의 reference를 받아온다.
final CollectionReference postsRef = Firestore.instance
    .collection('posts'); //Firestore로부터 'posts' collection의 reference를 받아온다.
final StorageReference storageRef =
    FirebaseStorage.instance.ref(); // 파이어베이스스토레이지에 저장할 때 사용하기 위한 레퍼런스
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  //Home Class는 StatefulWidget을 상속하는 객체이다, 말 그대로 첫 화면을 정의하고 구성한다
  @override //StatefulWidget의 기본 생성자인 createState()를 _HomeState를 생성하도록 정의
  _HomeState createState() =>
      _HomeState(); //화살표 함수(Arrow Function)은  함수 키워드 대신 화살표를 사용하여 보다 간략한 방법으로 함수를 선언하는 방법이다. 다만 모든 경우에 사용할 수 있는것이 아니므로 조심해서 사용해야 한다.
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error sigining in: $err');
    });
    // Reauthenticate user when app is opened
    // TODO: Commented Out because of error

    //googleSignIn.signInSilently(suppressErrors: false).then((GoogleSignInAccount account) {
    //  handleSignIn(account);
    //}).catchError((err) {
    //  print('Error sigining in: $err');
    //  if(err.code == 'sign_in_required'){
    //    print('login in 1st time');
    //    login();
    //  } else if(err.code == 'sign_in_failed'){
    //    print('sign in failed');
    //  }
    //});
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

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database(according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    if (!doc.exists) {
      // 2) if the user doesn't exists then we want to take them to the create account page
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateAccount())); //TODO: 이해

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    //구글로그인을 수행하기 위한 로그인 함수
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

  onTab(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          //Timeline(),
          RaisedButton(
            child: Text("Logout"),
            onPressed: logout,
          ),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTab,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Scaffold buildUnAuthScreen() {
    //인증 화면을 생성한다(스카폴드를 리턴함)
    return Scaffold(
      //스카폴드의 구조
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context)
                  .accentColor, //context:the location in the tree where widget locates
              Theme.of(context).primaryColor //It will bring thema of the parent
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'FlutterShare',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              //onTap: () => print('tapped'),
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage('assets/images/google_signin_button.png'),
                      fit: BoxFit.cover),
                ),
              ),
            )
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
