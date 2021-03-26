import 'package:Artis_Tree/models/post.dart';
import 'package:Artis_Tree/pages/Item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Artis_Tree/models/seller.dart';
import 'package:Artis_Tree/models/tile_builder.dart';
import 'package:flutter/rendering.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:Artis_Tree/models/user.dart';
import 'package:Artis_Tree/pages/create_account.dart';
import 'package:Artis_Tree/pages/customer_orders.dart';
import 'package:Artis_Tree/pages/profile.dart';
import 'package:Artis_Tree/pages/shopping.dart';
import 'package:Artis_Tree/pages/upload_item.dart';
import './progress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

import 'admin_orders.dart';
import 'dart:async';
import 'dart:io';

import 'notifs.dart';

final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final oRders = Firestore.instance.collection('Orders');
final rRef = Firestore.instance.collection('reviews');
final activityFeedRef = Firestore.instance.collection('feed');
final DateTime timestamp = DateTime.now();

User currentUser;
String sEller = "117815227641549443600";
String sEller1 = "106634878534939746619";

final facebookLogin = FacebookLogin();

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final StorageReference storageRef = FirebaseStorage.instance.ref();
bool isCat = false;
bool isEmail = false;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  bool isAuth = false;

  String name, email, pid;
  List<Post> posts = [];
  List<Post> search;
  PageController pageController;
  int pageIndex = 0;
  TextEditingController searchController = TextEditingController();

  String type = "";

  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _disp;
  String _password;
  String _errorMessage = "";

  bool _isLoginForm;
  bool _isLoading;

  // ignore: non_constant_identifier_names
  text_changer(String o, String n) {
    String x = o;

    o = o.toUpperCase();
    n = n.toUpperCase();
    print(o);
    print(n);
    String len = "";

    print(o.toUpperCase().indexOf(n.toUpperCase()));

    len = x.substring(0, o.indexOf(n)) +
        "(" +
        x.substring(o.indexOf(n), o.indexOf(n) + n.length) +
        ")" +
        x.substring(o.indexOf(n) + n.length, o.length);

    return len;
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      pageController = PageController();
      pageIndex = 0;
      search = null;
    });
  }

  handleSearch(String query) async {
    search = [];

    QuerySnapshot snaps =
        await postsRef.document(sEller).collection('userPosts').getDocuments();
    setState(() {
      posts = snaps.documents.map((doc) => Post.fromDocument(doc)).toList();
    });

    if (query == "")
      setState(() {
        search = posts;
      });
    else {
      setState(() {
        type = "item";
      });
      for (int i = 0; i < posts.length; i++)
        if (posts[i].item.toUpperCase().contains(query.toUpperCase()))
          search.add(posts[i]);

      if (search.length == 0) {
        setState(() {
          type = "seller";
        });
        for (int i = 0; i < posts.length; i++)
          if (posts[i].seller.toUpperCase().contains(query.toUpperCase()))
            search.add(posts[i]);
      }

      if (search.length == 0) {
        setState(() {
          type = "cat";
        });
        for (int i = 0; i < posts.length; i++)
          if (posts[i].category.toUpperCase().contains(query.toUpperCase()))
            search.add(posts[i]);
      }

      if (search.length == 0) {
        setState(() {
          type = "desc";
        });
        for (int i = 0; i < posts.length; i++)
          if (posts[i].description.toUpperCase().contains(query.toUpperCase()))
            search.add(posts[i]);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    pageController = PageController();

    fauth();
    google();
  }

  check() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    if (user != null) {
      setState(() {
        isLoading = true;
      });
      DocumentSnapshot doc = await usersRef.document(user.uid).get();
      currentUser = User.fromDocument(doc);

      setState(() {
        isLoading = false;
        isAuth = true;
      });
    }
  }

  fauth() {
    check();

    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
  }

  google() {
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      setState(() {
        isLoading = true;
      });
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  /* getseller() async {
    DocumentSnapshot doc = await usersRef.document("Seller").get();
    Seller seller = Seller.fromDocument(doc);

    setState(() {
      sEller = seller.id;
    });
  }*/

  handleSignIn(GoogleSignInAccount account) async {
    setState(() {
      isLoading = true;
    });

    if (account != null) {
      print('User signed in!: $account');
      await createUserInFirestore();

      setState(() {
        isAuth = true;
        isLoading = false;
        name = account.displayName;
        email = account.email;
        pid = account.photoUrl;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      String mobile = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "sellerId": sEller,
        "mobile": mobile.split("|")[0],
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "door": mobile.split("|")[1],
        "street": mobile.split("|")[2],
        "locality": mobile.split("|")[3],
        "city": mobile.split("|")[4],
        "zip": mobile.split("|")[5],
        "timestamp": timestamp
      });

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.displayName);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    setState(() {
      isLoading = true;
    });

    googleSignIn.signIn();

    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        isLoading = true;
      });
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });

    setState(() {
      isLoading = false;
    });
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
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
  }

  appbar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(75.0), // here the desired height
      child: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, size: 40), // change this size and style
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),
        title: TextFormField(
          autofocus: false,
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins-Regular"),
          controller: searchController,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              borderSide:
                  BorderSide(color: _getColorFromHex("#7338ac"), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              borderSide: BorderSide(color: _getColorFromHex("#7338ac")),
            ),
            contentPadding: EdgeInsets.all(8),
            hintText: "Search an item...",
            hintStyle: TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
                fontFamily: "Poppins-Regular"),
            filled: true,
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: _getColorFromHex("#7338ac"),
              ),
              onPressed: clearSearch,
            ),
          ),
          onFieldSubmitted: handleSearch,
        ),
        centerTitle: true,
        backgroundColor: _getColorFromHex("#f0f4ff"),
        elevation: 0,
        iconTheme: IconThemeData(
          color: _getColorFromHex("#7338ac"),
        ),
      ),
    );
  }

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget buildAuthScreen() {
    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          if (search == null && isCat == false) {
            showDialog(
                context: context,
                builder: (_) => new AlertDialog(
                        backgroundColor: Colors.white,
                        title: new Text("Are you sure??",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        content: new Text("Click yes to exit App",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.black)),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                exit(0);
                              },
                              child: Text("Yes",
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue))),
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No",
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue))),
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel",
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)))
                        ]));
          }
          if (isCat == true) {
            setState(() {
              isCat = false;
            });
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: _getColorFromHex("#f0f4ff"),
          appBar: appbar(),
          drawer: drawer(),
          body: PageView(
            children: <Widget>[
              Shopping(),
              Notifs(),
              Profile(),
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
            child: BottomNavigationBar(
                elevation: 20,
                iconSize: 30,
                backgroundColor: Colors.white,
                currentIndex: pageIndex,
                onTap: onTap,
                unselectedItemColor: _getColorFromHex("#635ad9"),
                selectedItemColor: _getColorFromHex("#7338ac"),
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      title: Text("Home",
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: (pageIndex == 0)
                                  ? "Poppins-Bold"
                                  : "Poppins-Regular")),
                      activeIcon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.notifications_active_outlined),
                      title: Text("Notifs",
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: (pageIndex == 1)
                                  ? "Poppins-Bold"
                                  : "Poppins-Regular")),
                      activeIcon: Icon(Icons.notifications_active)),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      title: Text("Account",
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: (pageIndex == 2)
                                  ? "Poppins-Bold"
                                  : "Poppins-Regular")),
                      activeIcon: Icon(Icons.account_circle)),
                ]),
          ),
        ));
  }

  Widget signup() {
    fun1() {
      showDialog(
          context: context,
          builder: (_) => new AlertDialog(
                title: new Text("ACCOUNT CREATED",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                content: Text("EMAIL\n$_email\nPASSWORD\n$_password",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ));
    }

    funx1() {
      showDialog(
          context: context,
          builder: (_) => new AlertDialog(
                title: new Text("ERROR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                content: Text("$_errorMessage",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ));
    }

    // Check if form is valid before perform login or signup
    bool validateAndSave() {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        return true;
      }
      return false;
    }

    // Perform login or signup
    void validateAndSubmit() async {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      if (validateAndSave()) {
        String userId = "";
        try {
          if (_isLoginForm) {
            AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
                email: _email, password: _password);
            FirebaseUser id = result.user;
            userId = id.uid;
            print('Signed in: $userId ');

            print(id.email);
            print(id.displayName);
            print(id.uid);
            print(id.photoUrl);

            {
              DocumentSnapshot doc = await usersRef.document(id.uid).get();

              if (!doc.exists) {
                // 2) if the user doesn't exist, then we want to take them to the create account page
                String mobile = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateAccount()));

                // 3) get username from create account, use it to make new user document in users collection
                usersRef.document(id.uid).setData({
                  "id": id.uid,
                  "sellerId": sEller,
                  "mobile": mobile.split("|")[0],
                  "photoUrl": "User",
                  "email": id.email,
                  "displayName": _disp,
                  "door": mobile.split("|")[1],
                  "street": mobile.split("|")[2],
                  "locality": mobile.split("|")[3],
                  "city": mobile.split("|")[4],
                  "zip": mobile.split("|")[5],
                  "timestamp": timestamp
                });

                doc = await usersRef.document(id.uid).get();
              }

              currentUser = User.fromDocument(doc);
              print(currentUser);
              print(currentUser.displayName);
            }

            setState(() {
              isAuth = true;
            });
          } else {
            AuthResult result =
                await _firebaseAuth.createUserWithEmailAndPassword(
                    email: _email, password: _password);
            //widget.auth.sendEmailVerification();
            //_showVerifyEmailSentDialog();
            FirebaseUser id = result.user;
            userId = id.uid;
            print('Signed up user: $userId ');

            fun1();
          }
          setState(() {
            _isLoading = false;
          });

          if (userId.length > 0 && userId != null && _isLoginForm) {}
        } catch (e) {
          print('Error: $e');

          setState(() {
            _isLoading = false;
            _errorMessage = e.message;
            _formKey.currentState.reset();
          });
          funx1();
        }
      } else {
        setState(() {
          _errorMessage = "Invalid Data Entry.Entry can\'t be NULL";
        });

        funx1();

        _isLoading = false;
      }
    }

    void resetForm() {
      _formKey.currentState.reset();
      _errorMessage = "";
    }

    void toggleFormMode() {
      resetForm();
      setState(() {
        _isLoginForm = !_isLoginForm;
      });
    }

    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        setState(() {
          isEmail = false;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Container(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/1.jpeg"), fit: BoxFit.cover),
            ),
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(""),
                    Center(
                        child: Icon(Icons.shopping_cart,
                            color: Colors.black, size: 150)),
                    Text(""),
                    !_isLoginForm
                        ? TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.name,
                            autofocus: false,
                            style: TextStyle(color: Colors.black),
                            decoration: new InputDecoration(
                              hintStyle: TextStyle(color: Colors.black54),
                              hintText: 'Display Name',
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                            ),
                            validator: (value) => value.isEmpty
                                ? 'Display Name can\'t be empty'
                                : null,
                            onSaved: (value) => _disp = value.trim(),
                          )
                        : Text(""),
                    Text(""),
                    TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      style: TextStyle(color: Colors.black),
                      decoration: new InputDecoration(
                        hintStyle: TextStyle(color: Colors.black54),
                        hintText: 'Email',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'Email can\'t be empty' : null,
                      onSaved: (value) => _email = value.trim(),
                    ),
                    Text(""),
                    TextFormField(
                      maxLines: 1,
                      obscureText: true,
                      autofocus: false,
                      style: TextStyle(color: Colors.black),
                      decoration: new InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'Password can\'t be empty' : null,
                      onSaved: (value) => _password = value.trim(),
                    ),
                    Text(""),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: RaisedButton(
                        color: _getColorFromHex("#f0f4ff"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.black)),
                        child:
                            new Text(_isLoginForm ? 'Login' : 'Create account',
                                style: new TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  color: Colors.black,
                                  fontSize: 15.0,
                                )),
                        onPressed: validateAndSubmit,
                      ),
                    ),
                    Text(""),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: GestureDetector(
                        onTap: toggleFormMode,
                        child: Text(
                            _isLoginForm
                                ? 'New User? Create an account'
                                : 'Have an account? Sign in',
                            style: new TextStyle(
                              fontFamily: "Poppins-Regular",
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Text(""),
                    (_isLoading == true) ? circularProgress() : Text("")
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/1.jpeg"), fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(flex: 8, child: Text("")),
            Expanded(
              flex: 8,
              child: Center(
                  child: Icon(Icons.shopping_cart,
                      color: Colors.black, size: 150)),
            ),
            Expanded(flex: 4, child: Text("")),
            Expanded(
              flex: 2,
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: RaisedButton(
                  onPressed: () async {
                    final result = await facebookLogin.logIn(permissions: [
                      FacebookPermission.publicProfile,
                      FacebookPermission.email
                    ]);

                    print(result.status.toString());
                    switch (result.status) {
                      case FacebookLoginStatus.success:
                        print('It worked');

                        //Get Token
                        final FacebookAccessToken fbToken = result.accessToken;

                        //Convert to Auth Credential
                        final AuthCredential credential =
                            FacebookAuthProvider.getCredential(
                                accessToken: fbToken.token);

                        //User Credential to Sign in with Firebase
                        // final result = await authService.signInWithCredentail(credential);

                        // print('${result.user.displayName} is now logged in');

                        break;
                      case FacebookLoginStatus.cancel:
                        print('The user canceled the login');
                        break;
                      case FacebookLoginStatus.error:
                        print('There was an error');
                        break;
                    }
                  },
                  color: _getColorFromHex("#f0f4ff"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.black)),
                  child: Text(
                    "Sign in with Facebook",
                    style: TextStyle(
                      fontFamily: "Poppins-Regular",
                      color: Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(flex: 1, child: Text("")),
            Expanded(
              flex: 2,
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: RaisedButton(
                  onPressed: (isEmail == true)
                      ? () {
                          print("logged in");
                        }
                      : login,
                  color: _getColorFromHex("#f0f4ff"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.black)),
                  child: Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontFamily: "Poppins-Regular",
                      color: Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(flex: 2, child: Text("")),
            Expanded(
              flex: 2,
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      isEmail = true;
                    });
                  },
                  color: _getColorFromHex("#f0f4ff"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.black)),
                  child: Text(
                    "Log In / Sign Up",
                    style: TextStyle(
                      fontFamily: "Poppins-Regular",
                      color: Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: (isLoading == true) ? circularProgress() : Text("")),
            Expanded(flex: 8, child: Text("")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return screens();
  }

  buildSearchResults() {
    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          setState(() {
            search = null;
          });
        },
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: _getColorFromHex("#f0f4ff"),
            appBar: appbar(),
            drawer: drawer(),
            body: Container(
                color: _getColorFromHex("#f0f4ff"),
                child: (search.length > 0)
                    ? ListView.separated(
                        itemCount: search.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostScreenX(
                                    postId: search[index].postId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                color: _getColorFromHex("#911482")
                                    .withOpacity(0.5),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: AspectRatio(
                                                  aspectRatio: 4 / 5,
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    imageUrl:
                                                        search[index].mediaUrl,
                                                    placeholder:
                                                        (context, url) =>
                                                            Padding(
                                                      child:
                                                          CircularProgressIndicator(),
                                                      padding:
                                                          EdgeInsets.all(4),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ))),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              (type == "item" &&
                                                      searchController.text !=
                                                          "")
                                                  ? RichText(
                                                      text: TextSpan(
                                                        text: search[index].item.substring(
                                                            0,
                                                            search[index]
                                                                .item
                                                                .toUpperCase()
                                                                .indexOf(
                                                                    searchController
                                                                        .text
                                                                        .toUpperCase())),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          color: Colors.black,
                                                          fontSize: 13.0,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: search[index].item.substring(
                                                                  search[index]
                                                                      .item
                                                                      .toUpperCase()
                                                                      .indexOf(searchController
                                                                          .text
                                                                          .toUpperCase()),
                                                                  search[index]
                                                                          .item
                                                                          .toUpperCase()
                                                                          .indexOf(searchController
                                                                              .text
                                                                              .toUpperCase()) +
                                                                      searchController
                                                                          .text
                                                                          .length),
                                                              style: TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .yellow,
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13.0,
                                                              )),
                                                          TextSpan(
                                                              text: search[index].item.substring(
                                                                      search[index].item.toUpperCase().indexOf(searchController
                                                                              .text
                                                                              .toUpperCase()) +
                                                                          searchController
                                                                              .text
                                                                              .length,
                                                                      search[index]
                                                                          .item
                                                                          .length) +
                                                                  " - ",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0,
                                                              )),
                                                          TextSpan(
                                                              text:
                                                                  "${search[index].cash} Rs\n",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13.0,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  : RichText(
                                                      text: TextSpan(
                                                        text:
                                                            "${search[index].item} - ",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          color: Colors.black,
                                                          fontSize: 13.0,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text:
                                                                  "${search[index].cash} Rs\n",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13.0,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                              (type == "seller")
                                                  ? RichText(
                                                      text: TextSpan(
                                                        text: 'Sold by : ' +
                                                            search[index].seller.substring(
                                                                0,
                                                                search[index]
                                                                    .seller
                                                                    .toUpperCase()
                                                                    .indexOf(searchController
                                                                        .text
                                                                        .toUpperCase())),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          color: Colors.black,
                                                          fontSize: 13.0,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: search[index].seller.substring(
                                                                  search[index]
                                                                      .seller
                                                                      .toUpperCase()
                                                                      .indexOf(searchController
                                                                          .text
                                                                          .toUpperCase()),
                                                                  search[index]
                                                                          .seller
                                                                          .toUpperCase()
                                                                          .indexOf(searchController
                                                                              .text
                                                                              .toUpperCase()) +
                                                                      searchController
                                                                          .text
                                                                          .length),
                                                              style: TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .yellow,
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13.0,
                                                              )),
                                                          TextSpan(
                                                              text: search[index].seller.substring(
                                                                  search[index]
                                                                          .seller
                                                                          .toUpperCase()
                                                                          .indexOf(searchController
                                                                              .text
                                                                              .toUpperCase()) +
                                                                      searchController
                                                                          .text
                                                                          .length,
                                                                  search[index]
                                                                      .seller
                                                                      .length),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0,
                                                              )),
                                                          TextSpan(
                                                              text: "\n",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  : Text(
                                                      "Sold by : ${search[index].seller}\n",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                      )),
                                              (type == "cat")
                                                  ? RichText(
                                                      text: TextSpan(
                                                        text: 'Category : ' +
                                                            search[index].category.substring(
                                                                0,
                                                                search[index]
                                                                    .category
                                                                    .toUpperCase()
                                                                    .indexOf(searchController
                                                                        .text
                                                                        .toUpperCase())),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          color: Colors.black,
                                                          fontSize: 13.0,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: search[index].category.substring(
                                                                  search[index]
                                                                      .category
                                                                      .toUpperCase()
                                                                      .indexOf(searchController
                                                                          .text
                                                                          .toUpperCase()),
                                                                  search[index]
                                                                          .category
                                                                          .toUpperCase()
                                                                          .indexOf(searchController
                                                                              .text
                                                                              .toUpperCase()) +
                                                                      searchController
                                                                          .text
                                                                          .length),
                                                              style: TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .yellow,
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13.0,
                                                              )),
                                                          TextSpan(
                                                              text: search[index].category.substring(
                                                                  search[index]
                                                                          .category
                                                                          .toUpperCase()
                                                                          .indexOf(searchController
                                                                              .text
                                                                              .toUpperCase()) +
                                                                      searchController
                                                                          .text
                                                                          .length,
                                                                  search[index]
                                                                      .category
                                                                      .length),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0,
                                                              )),
                                                          TextSpan(
                                                              text: "\n",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  : Text(
                                                      "Category : ${search[index].category}\n",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                      )),
                                              (type == "desc")
                                                  ? RichText(
                                                      text: TextSpan(
                                                        text: 'Description : ' +
                                                            search[index].description.substring(
                                                                0,
                                                                search[index]
                                                                    .description
                                                                    .toUpperCase()
                                                                    .indexOf(searchController
                                                                        .text
                                                                        .toUpperCase())),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          color: Colors.black,
                                                          fontSize: 13.0,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: search[index].description.substring(
                                                                  search[index]
                                                                      .description
                                                                      .toUpperCase()
                                                                      .indexOf(searchController
                                                                          .text
                                                                          .toUpperCase()),
                                                                  search[index]
                                                                          .description
                                                                          .toUpperCase()
                                                                          .indexOf(searchController
                                                                              .text
                                                                              .toUpperCase()) +
                                                                      searchController
                                                                          .text
                                                                          .length),
                                                              style: TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .yellow,
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13.0,
                                                              )),
                                                          TextSpan(
                                                              text: search[index].description.substring(
                                                                  search[index]
                                                                          .description
                                                                          .toUpperCase()
                                                                          .indexOf(searchController
                                                                              .text
                                                                              .toUpperCase()) +
                                                                      searchController
                                                                          .text
                                                                          .length,
                                                                  search[index]
                                                                      .description
                                                                      .length),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0,
                                                              )),
                                                          TextSpan(
                                                              text: "\n",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins-Regular",
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  : Text(
                                                      "Description : ${search[index].description}",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                      )),
                                            ],
                                          )),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              Text("\n\n\n\n\n\n\n",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                  )),
                                              Text(
                                                  "${ordered(search[index].timestamp.toDate()).substring(0, 11)}",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black,
                                                    fontSize: 11,
                                                  )),
                                            ],
                                          )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            size: 300,
                            color: _getColorFromHex("#4c004c"),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              "RESULTS NOT FOUND!!!\nTRY AGAIN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _getColorFromHex("#4c004c"),
                                  fontFamily: "Bangers",
                                  fontSize: 50.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 10.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  _getColorFromHex("#4c004c"),
                                ),
                              )),
                        ],
                      )))));
  }

  screens() {
    if (isAuth == false && isEmail == false)
      return buildUnAuthScreen();
    else if (isAuth == false && isEmail == true)
      return signup();
    else if (isAuth == true && search == null)
      return buildAuthScreen();
    else if (isAuth == true && search != null) return buildSearchResults();
  }

  Drawer drawer() {
    return Drawer(
      child: (currentUser.id == sEller || currentUser.id == sEller1)
          ? ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  color: _getColorFromHex("#7338ac"),
                  child: DrawerHeader(
                      margin: EdgeInsets.only(bottom: 0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: _getColorFromHex("#f0f4ff"),
                                child: Text("${currentUser.displayName[0]}",
                                    style: TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.w700,
                                        color: _getColorFromHex("#7338ac"),
                                        fontFamily: "Poppins-Bold")),
                              ),
                            ),
                            Center(
                              child: Text(
                                  "Hello ${currentUser.displayName.split(" ")[0]}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: _getColorFromHex("#f0f4ff"),
                                      fontFamily: "Poppins-Bold")),
                            ),
                          ])),
                ),
                ListTile(
                    title: Text('Sell an Item',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Upload(
                            currentUser: currentUser,
                          ),
                        ),
                      );
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
                ListTile(
                    title: Text('Orders Received',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Aorders(
                            screen: "drawer",
                          ),
                        ),
                      );
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
                ListTile(
                    title: Text('Logout',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(Duration(seconds: 3), () {
                              Navigator.of(context).pop(true);
                            });
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: new Text("Logging out!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              content: Container(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: LinearProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black),
                                ),
                              ),
                            );
                          });

                      Future.delayed(Duration(seconds: 3), () {
                        googleSignIn.signOut();
                        _firebaseAuth.signOut();

                        setState(() {
                          isAuth = false;
                          isEmail = false;
                        });
                      });

                      setState(() {
                        pageIndex = 0;
                      });
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
              ],
            )
          : ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  color: _getColorFromHex("#7338ac"),
                  child: DrawerHeader(
                      margin: EdgeInsets.only(bottom: 0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: _getColorFromHex("#f0f4ff"),
                                child: Text("${currentUser.displayName[0]}",
                                    style: TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.w700,
                                        color: _getColorFromHex("#7338ac"),
                                        fontFamily: "Poppins-Bold")),
                              ),
                            ),
                            Center(
                              child: Text(
                                  "Hello ${currentUser.displayName.split(" ")[0]}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: _getColorFromHex("#f0f4ff"),
                                      fontFamily: "Poppins-Bold")),
                            ),
                          ])),
                ),
                ListTile(
                    title: Text('My Orders',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Corders(
                            currentUser: currentUser,
                            screen: "drawer",
                          ),
                        ),
                      );
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
                ListTile(
                    title: Text('Logout',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(Duration(seconds: 3), () {
                              Navigator.of(context).pop(true);
                            });
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: new Text("Logging out!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              content: Container(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: LinearProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black),
                                ),
                              ),
                            );
                          });

                      Future.delayed(Duration(seconds: 3), () {
                        googleSignIn.signOut();
                        _firebaseAuth.signOut();

                        setState(() {
                          isAuth = false;
                          isEmail = false;
                        });
                      });

                      setState(() {
                        pageIndex = 0;
                      });
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
              ],
            ),
    );
  }
}

Color _getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
}
