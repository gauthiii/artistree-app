import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Artis_Tree/models/item_tile.dart';
import 'package:Artis_Tree/models/post.dart';
import 'package:Artis_Tree/pages/admin_orders.dart';
import 'package:Artis_Tree/pages/customer_orders.dart';
import 'package:Artis_Tree/pages/home.dart';
import 'package:Artis_Tree/pages/post_screen.dart';
import 'package:Artis_Tree/pages/Item.dart';
import 'package:Artis_Tree/pages/progress.dart';
import 'package:Artis_Tree/pages/upload_item.dart';

class Shopping extends StatefulWidget {
  @override
  _ShoppingState createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  bool isLoading = false;

  String cat;
  List<Post> her = [];
  List<Post> him = [];
  List<Post> dad = [];
  List<Post> mom = [];
  List<Post> bro = [];
  List<Post> sis = [];
  List<Post> fri = [];
  int postCount = 0;
  List<Post> posts = [];
  @override
  void initState() {
    super.initState();
    getPosts();
  }

  bg() {
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].category == "For Her") {
        her.add(posts[i]);
      } else if (posts[i].category == "For Him") {
        him.add(posts[i]);
      } else if (posts[i].category == "Dad") {
        dad.add(posts[i]);
      } else if (posts[i].category == "Mom") {
        mom.add(posts[i]);
      } else if (posts[i].category == "Brother") {
        bro.add(posts[i]);
      } else if (posts[i].category == "Sister") {
        sis.add(posts[i]);
      } else if (posts[i].category == "Friend") {
        fri.add(posts[i]);
      }
    }

    for (int i = 0; i < her.length; i++) print(her[i].item);
    for (int i = 0; i < him.length; i++) print(him[i].item);
    for (int i = 0; i < bro.length; i++) print(bro[i].item);
    for (int i = 0; i < sis.length; i++) print(sis[i].item);
    for (int i = 0; i < dad.length; i++) print(dad[i].item);
    for (int i = 0; i < mom.length; i++) print(mom[i].item);
    for (int i = 0; i < fri.length; i++) print(fri[i].item);
  }

  getPosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(sEller)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 250,
              color: Colors.black,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts!!!!!",
                style: TextStyle(
                  fontFamily: "Bangers",
                  color: Colors.black,
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
  }

  buildPosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 250,
              color: Colors.black,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts!!!!!",
                style: TextStyle(
                  fontFamily: "Bangers",
                  color: Colors.black,
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return list();
    }
  }

  Future<String> apiCallLogic() async {
    getPosts();

    return Future.value("Hello World");
  }

  list() {
    return FutureBuilder(
      future: apiCallLogic(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData)
          return ListView(
              padding: EdgeInsets.only(top: 24),
              scrollDirection: Axis.horizontal,
              children: List.generate(posts.length, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostScreenX(postId: posts[index].postId),
                      ),
                    );
                  },
                  child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: posts[index].mediaUrl,
                            placeholder: (context, url) => Padding(
                              child: CircularProgressIndicator(),
                              padding: EdgeInsets.all(4),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ))),
                );
              }));
        else
          return const Text('Some error happened');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCat == false)
      return Scaffold(
        backgroundColor: _getColorFromHex("#f0f4ff"),
        body: Column(
          children: <Widget>[
            Expanded(flex: 1, child: Text("")),
            Expanded(
                flex: 2,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                    height: 50,
                    child: Card(
                      color: _getColorFromHex("#f0f4ff"),
                      elevation: 0,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: _getColorFromHex("#635ad9"),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          padding: EdgeInsets.all(2),
                          alignment: Alignment.center,
                          child: Text(
                            "What's New?",
                            style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          )),
                    ),
                  ),
                ])),
            Expanded(flex: 6, child: buildPosts()),
            Expanded(flex: 1, child: Text("")),
            Expanded(
                flex: 2,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 50,
                        child: Card(
                          color: _getColorFromHex("#f0f4ff"),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _getColorFromHex("#635ad9"),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text(
                                "Categories",
                                style: TextStyle(
                                  fontFamily: "Poppins-Bold",
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  fontSize: 16.0,
                                ),
                              )),
                        ),
                      ),
                    ])),
            Expanded(
              flex: 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCat = true;
                          cat = "For Her";
                        });
                        her = [];
                        bg();
                      },
                      child: Container(
                        child: Card(
                          color: _getColorFromHex("#88f4ff"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 35,
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                "For Her",
                                style: TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCat = true;
                          cat = "Dad";
                        });
                        dad = [];
                        bg();
                      },
                      child: Container(
                        child: Card(
                          color: _getColorFromHex("#88f4ff"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 35,
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                "Dad",
                                style: TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ]),
            ),
            Expanded(
              flex: 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCat = true;
                          cat = "For Him";
                        });
                        him = [];
                        bg();
                      },
                      child: Container(
                        child: Card(
                          color: _getColorFromHex("#88f4ff"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 35,
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                "For Him",
                                style: TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCat = true;
                          cat = "Mom";
                        });
                        mom = [];
                        bg();
                      },
                      child: Container(
                        child: Card(
                          color: _getColorFromHex("#88f4ff"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 35,
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                "Mom",
                                style: TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ]),
            ),
            Expanded(
              flex: 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCat = true;
                          cat = "Brother";
                        });
                        bro = [];
                        bg();
                      },
                      child: Container(
                        child: Card(
                          color: _getColorFromHex("#88f4ff"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 35,
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                "Brother",
                                style: TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCat = true;
                          cat = "Sister";
                        });
                        sis = [];
                        bg();
                      },
                      child: Container(
                        child: Card(
                          color: _getColorFromHex("#88f4ff"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 35,
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                "Sister",
                                style: TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ]),
            ),
            Expanded(
              flex: 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCat = true;
                          cat = "Friend";
                        });
                        fri = [];
                        bg();
                      },
                      child: Container(
                        child: Card(
                          color: _getColorFromHex("#88f4ff"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 35,
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                "Friend",
                                style: TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCat = true;
                          cat = "Customized";
                        });
                      },
                      child: Container(
                        child: Card(
                          color: _getColorFromHex("#88f4ff"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 35,
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                "Customized",
                                style: TextStyle(
                                  fontFamily: "Poppins-Regular",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ]),
            ),
            Expanded(flex: 2, child: Text("")),
          ],
        ),
      );
    else if (isCat == true)
      return WillPopScope(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(80.0), // here the desired height
                child: AppBar(
                    elevation: 0,
                    backgroundColor: _getColorFromHex("#f0f4ff"),
                    centerTitle: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: DropdownButton<String>(
                            dropdownColor: _getColorFromHex("#f0f4ff"),
                            value: cat,
                            icon: null,
                            iconEnabledColor: Colors.black,
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.black,
                                fontFamily: "Poppins-Regular"),
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                cat = newValue;
                              });
                              her = [];
                              him = [];
                              dad = [];
                              mom = [];
                              bro = [];
                              sis = [];
                              fri = [];
                              bg();
                            },
                            items: <String>[
                              "For Her",
                              "For Him",
                              "Dad",
                              "Mom",
                              "Brother",
                              "Sister",
                              "Friend",
                              "Customized",
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                onTap: () {
                                  setState(() {
                                    cat = value;
                                  });
                                  print(cat);
                                },
                                value: value,
                                child: Container(
                                  child: Card(
                                    color: _getColorFromHex("#f0f4ff"),
                                    elevation: 0,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  _getColorFromHex("#635ad9"),
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        padding: EdgeInsets.all(4),
                                        alignment: Alignment.center,
                                        child: Text(value,
                                            style: TextStyle(
                                              fontFamily: "Poppins-Bold",
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                              fontSize: 20.0,
                                            ),
                                            textAlign: TextAlign.center)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ))),
            backgroundColor: _getColorFromHex("#f0f4ff"),
            body: orders_list(cat_chooser())),
        // ignore: missing_return
        onWillPop: () {
          setState(() {
            isCat = false;
          });
        },
      );
  }

  List<Post> cat_chooser() {
    if (cat == "For Her")
      return her;
    else if (cat == "For Him")
      return him;
    else if (cat == "Dad")
      return dad;
    else if (cat == "Mom")
      return mom;
    else if (cat == "Brother")
      return bro;
    else if (cat == "Sister")
      return sis;
    else if (cat == "Friend")
      return fri;
    else if (cat == "Customized") return posts;
  }

  orders_list(List<Post> her) {
    return (her.length > 0)
        ? ListView.separated(
            itemCount: her.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostScreenX(
                        postId: her[index].postId,
                      ),
                    ),
                  );
                },
                child: Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    color: _getColorFromHex("#911482").withOpacity(0.5),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: AspectRatio(
                                      aspectRatio: 4 / 5,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: her[index].mediaUrl,
                                        placeholder: (context, url) => Padding(
                                          child: CircularProgressIndicator(),
                                          padding: EdgeInsets.all(4),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ))),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("${her[index].item}\n",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 13.0,
                                      )),
                                  Text("Sold by : ${her[index].seller}\n",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 13.0,
                                      )),
                                  Text("Price : ${her[index].cash} Rs\n",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 13.0,
                                      )),
                                  Text("Category : ${her[index].category}",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text("\n\n\n\n\n\n\n",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 12.0,
                                      )),
                                  Text(
                                      "Posted on : ${ordered(her[index].timestamp.toDate()).substring(0, 6)}",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
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
                size: 250,
                color: _getColorFromHex("#4c004c"),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "RESULTS NOT FOUND!!!\nCHOOSE A DIFFERENT CATEGORY",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _getColorFromHex("#4c004c"),
                      fontFamily: "Bangers",
                      fontSize: 30.0,
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
          ));
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
