import 'dart:io';
import 'package:Artis_Tree/pages/admin_orders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:Artis_Tree/models/user.dart';
import 'package:Artis_Tree/pages/img.dart';

import 'package:Artis_Tree/pages/progress.dart';

import './home.dart';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController seller = TextEditingController();
  TextEditingController item = TextEditingController();
  TextEditingController desc = TextEditingController();
  String category;
  TextEditingController cash = TextEditingController();
  TextEditingController link = TextEditingController();
  String i = "";
  String s = "";
  String d = "";
  String c = "";

  String dropdownValue = "For Her";
  List cat = [
    "For Her",
    "For Him",
    "Dad",
    "Mom",
    "Brother",
    "Sister",
    "Friend",
  ];

  File file;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
    _cropImage();
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
    _cropImage();
  }

  _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.grey[900],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() {
        file = croppedFile;
      });
    }
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Scaffold buildSplashScreen() {
    return Scaffold(
      backgroundColor: _getColorFromHex("#f0f4ff"),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(
          "Upload Post",
          style: TextStyle(),
        ),
      ),
      body: Center(
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: AspectRatio(
                aspectRatio: 3 / 2,
                child: DottedBorder(
                  color: Colors.black,
                  strokeWidth: 1,
                  child: GestureDetector(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text("",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular")),
                          ),
                          Container(
                            height: 70,
                            width: 100,
                            child: RaisedButton(
                                elevation: 0,
                                color: _getColorFromHex("#f0f4ff"),
                                onPressed: () {
                                  selectImage(context);
                                },
                                child: Icon(
                                  Icons.file_upload,
                                  size: 64,
                                  color: Colors.grey[800],
                                )),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text("\nUpload image",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular")),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {},
                  ),
                )),
          ),
        ),
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl,
      String seller,
      String item,
      String cash,
      String link,
      String description}) {
    final DateTime timestamp1 = DateTime.now();
    postsRef.document(sEller).collection("userPosts").document(postId).setData({
      "postId": postId,
      "seller": seller,
      "item": item,
      "mediaUrl": mediaUrl,
      "description": description,
      "link": link,
      "isBought": false,
      "cash": cash,
      "timestamp": timestamp1,
      "category": category
    });
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("POST UPLOADED!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "JustAnotherHand",
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);

    createPostInFirestore(
      mediaUrl: mediaUrl,
      seller: seller.text,
      item: item.text,
      cash: cash.text,
      link: link.text,
      description: desc.text,
    );

    seller.clear();
    item.clear();
    cash.clear();
    desc.clear();
    link.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
    Navigator.pop(context);
    Navigator.pop(context);

    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.white,
              title: new Text("Item Uploaded!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));
  }

  getDetails() {
    setState(() {
      i = item.text;
      c = cash.text;
      s = seller.text;
      d = desc.text;
    });
  }

  Future<String> apiCallLogic() async {
    getDetails();

    return Future.value("Hello World");
  }

  WillPopScope buildUploadForm() {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        clearImage();
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            leading:
                IconButton(icon: Icon(Icons.arrow_back), onPressed: clearImage),
            title: Text(
              "Upload Post",
              style: TextStyle(),
            ),
            actions: [
              FlatButton(
                onPressed: isUploading
                    ? null
                    : () {
                        if (seller.text != "" &&
                            item.text != "" &&
                            cash.text != "" &&
                            desc.text != "" &&
                            link.text != "")
                          handleSubmit();
                        else
                          showDialog(
                              context: context,
                              builder: (_) => new AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: new Text("Fields can't be blank !!!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ));
                      },
                child: Text(
                  "Post",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: FutureBuilder(
              future: apiCallLogic(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData)
                  return ListView(
                    padding: EdgeInsets.all(10),
                    children: <Widget>[
                      isUploading ? linearProgress() : Text(""),
                      Container(
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
                                              child: Image.file(file,
                                                  fit: BoxFit.fill)))),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                            text: 'Itemname : ',
                                            style: TextStyle(
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black,
                                              fontSize: 13.0,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: i,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.0,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            text: '\nSold by : ',
                                            style: TextStyle(
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black,
                                              fontSize: 13.0,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: s,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.0,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            text: '\nPrice:  ',
                                            style: TextStyle(
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black,
                                              fontSize: 13.0,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: c,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.0,
                                                  )),
                                              TextSpan(
                                                  text: " Rs",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.0,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            text: '\nDescription : ',
                                            style: TextStyle(
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black,
                                              fontSize: 13.0,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: d,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.0,
                                                  )),
                                            ],
                                          ),
                                        ),
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
                                            "Posted on : ${ordered(Timestamp.now().toDate()).substring(0, 6)}",
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
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                            child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              i = value;
                            });
                          },
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular"),
                          controller: item,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            labelText: "Item Name",
                            labelStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                            hintText: "Enter Item Name",
                            hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                          ),
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                            child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              s = value;
                            });
                          },
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular"),
                          controller: seller,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            labelText: "Seller Name",
                            labelStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                            hintText: "Enter Seller Name",
                            hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                          ),
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                            child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              d = value;
                            });
                          },
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular"),
                          controller: desc,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            labelText: "Description",
                            labelStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                            hintText: "Enter Description",
                            hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                          ),
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          child: DropdownButton<String>(
                            dropdownColor: _getColorFromHex("#f0f4ff"),
                            value: dropdownValue,
                            icon: Text(
                              " ( Tap to change the category )",
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                  fontFamily: "Poppins-Regular"),
                            ),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.black,
                                fontFamily: "Poppins-Regular"),
                            underline: Container(
                              height: 1,
                              color: Colors.black,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                              });
                            },
                            items: <String>[
                              "For Her",
                              "For Him",
                              "Dad",
                              "Mom",
                              "Brother",
                              "Sister",
                              "Friend",
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                onTap: () {
                                  setState(() {
                                    category = value;
                                  });
                                  print(category);
                                },
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                            child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              c = value;
                            });
                          },
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular"),
                          controller: cash,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            labelText: "Cost",
                            labelStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                            hintText: "Enter Cost",
                            hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                          ),
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                            child: TextFormField(
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular"),
                          controller: link,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            labelText: "Instagram Link",
                            labelStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                            hintText: "Enter Insta link url",
                            hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                          ),
                        )),
                      ),
                    ],
                  );
                else
                  return const Text('Some error happened');
              })),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
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
