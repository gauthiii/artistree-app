import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Artis_Tree/models/Rev.dart';
import 'package:Artis_Tree/models/tile_builder.dart';
import 'package:Artis_Tree/models/user.dart';
import 'package:Artis_Tree/pages/home.dart';
import 'package:Artis_Tree/pages/progress.dart';

class Reviews extends StatefulWidget {
  String postId, mediaUrl, seller, item;
  Reviews({this.postId, this.mediaUrl, this.seller, this.item});
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Reviews> {
  List stars = [];
  List<User> customer = [];
  bool isloading = false;
  bool nada = false;
  @override
  void initState() {
    super.initState();
    getReviews();
  }

  getReviews() async {
    setState(() {
      isloading = true;
    });
    DocumentSnapshot doc = await rRef.document(widget.postId).get();
    Fid d = Fid.fromDocument(doc);

    if (!doc.exists) {
      setState(() {
        isloading = false;
        stars = ["empty"];
      });
      print(stars);
    }

    for (int i = 0; i < d.fid.length; i++) {
      stars.add(d.fid[i].split("-")[0][0]);
      DocumentSnapshot d1 =
          await usersRef.document(d.fid[i].split("-")[1]).get();
      User u = User.fromDocument(d1);
      customer.add(u);
    }

    print(customer[0].displayName);
    print(stars);
    setState(() {
      isloading = false;
      if (isloading == false && stars[0] == "empty") nada = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isloading == true)
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Reviews"),
          ),
          backgroundColor: Colors.pink[100],
          body: circularProgress());
    else if (nada == true)
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Reviews"),
          ),
          backgroundColor: Colors.pink[100],
          body: Center(
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
                    "NO REVIEWS !!!!",
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
          ));
    else if (stars.isNotEmpty)
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Reviews"),
          ),
          backgroundColor: Colors.pink[100],
          body: (stars.length > 0)
              ? ListView(
                  children: List.generate(
                  stars.length,
                  (index) {
                    List rate = [false, false, false, false, false];
                    if (stars[index] == "1")
                      rate = [true, false, false, false, false];
                    else if (stars[index] == "2")
                      rate = [true, true, false, false, false];
                    else if (stars[index] == "3")
                      rate = [true, true, true, false, false];
                    else if (stars[index] == "4")
                      rate = [true, true, true, true, false];
                    else if (stars[index] == "5")
                      rate = [true, true, true, true, true];

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      color: Colors.red[300],
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {},
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                child: Icon(Icons.account_circle,
                                    color: Colors.black, size: 45),
                                backgroundColor: Colors.red[300],
                              ),
                              title: Text(
                                customer[index].displayName,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                              subtitle: Row(
                                children: <Widget>[
                                  (rate[0] == false)
                                      ? Icon(Icons.star_border,
                                          color: Colors.black, size: 15)
                                      : Icon(Icons.star,
                                          color: Colors.black, size: 15),
                                  (rate[1] == false)
                                      ? Icon(Icons.star_border,
                                          color: Colors.black, size: 15)
                                      : Icon(Icons.star,
                                          color: Colors.black, size: 15),
                                  (rate[2] == false)
                                      ? Icon(Icons.star_border,
                                          color: Colors.black, size: 15)
                                      : Icon(Icons.star,
                                          color: Colors.black, size: 15),
                                  (rate[3] == false)
                                      ? Icon(Icons.star_border,
                                          color: Colors.black, size: 15)
                                      : Icon(Icons.star,
                                          color: Colors.black, size: 15),
                                  (rate[4] == false)
                                      ? Icon(Icons.star_border,
                                          color: Colors.black, size: 15)
                                      : Icon(Icons.star,
                                          color: Colors.black, size: 15),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ))
              : Text(""));
  }

  reviews() {
    return ListView(
        children: List.generate(
      stars.length,
      (index) {
        return Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {},
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.account_circle,
                        color: Colors.black, size: 50),
                    backgroundColor: Colors.pink[100],
                  ),
                  title: Text(
                    customer[index].displayName,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  subtitle: Text(
                    stars[index],
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              Divider(
                height: 2.0,
                color: Colors.white54,
              ),
            ],
          ),
        );
      },
    ));
  }

  buildPostHeader() {
    return ListTile(
      leading: CircleAvatar(
        child: cachedNetworkImage(widget.mediaUrl),
        backgroundColor: Colors.pink[100],
      ),
      title: GestureDetector(
        onTap: () {},
        child: Text(
          widget.item,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      subtitle: Text(
        "Sold by " + widget.seller,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
