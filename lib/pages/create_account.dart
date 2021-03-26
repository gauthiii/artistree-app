import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Artis_Tree/pages/progress.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final _formKey4 = GlobalKey<FormState>();
  final _formKey5 = GlobalKey<FormState>();

  bool loc = false;

  TextEditingController mob = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController locationController2 = TextEditingController();
  TextEditingController locationController3 = TextEditingController();
  TextEditingController locationController4 = TextEditingController();
  TextEditingController locationController5 = TextEditingController();
  String username = "";

  submit() {
    username = mob.text +
        "|" +
        locationController.text +
        "|" +
        locationController2.text +
        "|" +
        locationController3.text +
        "|" +
        locationController4.text +
        "|" +
        locationController5.text;

    Navigator.pop(context, username);
    fun();
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.white,
              title: new Text("Details Saved !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));

    Navigator.pop(context);
  }

  fun1() {
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
  }

  getUserLocation() async {
    setState(() {
      loc = true;
    });

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(placemark.subThoroughfare);
    print(placemark.thoroughfare);
    print(placemark.subLocality);
    print(placemark.locality);
    print(placemark.subAdministrativeArea);
    print(placemark.administrativeArea);
    print(placemark.postalCode);
    print(placemark.country);
    String formattedAddress =
        "${placemark.subThoroughfare},${placemark.thoroughfare},${placemark.subLocality},${placemark.locality},${placemark.subAdministrativeArea},${placemark.administrativeArea},${placemark.postalCode},${placemark.country}";
    locationController.text = placemark.subThoroughfare;
    locationController2.text = placemark.thoroughfare;
    locationController3.text = placemark.subLocality;
    locationController4.text = placemark.locality;
    locationController5.text = placemark.postalCode;

    setState(() {
      loc = false;
    });
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _getColorFromHex("#f0f4ff"),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        /*   leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),*/
        automaticallyImplyLeading: false,
        title: Text(
          "Enter the following the details",
          style: TextStyle(),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Enter your mobile number",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins-Regular"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        validator: (val) {
                          if (val.trim().length != 10) {
                            return "Invalid Number";
                          } else {
                            return null;
                          }
                        },
                        controller: mob,
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
                          labelText: "Mobile Number",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter a valid number",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Enter your billing address",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins-Regular"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey1,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController,
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
                          labelText: "Door Number",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Door Number",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey2,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController2,
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
                          labelText: "Street",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Street Name",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey3,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController3,
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
                          labelText: "Locality",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Locality Name",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey4,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController4,
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
                          labelText: "City",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter City",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey5,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController5,
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
                          labelText: "Zip Code",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Zip Code",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                ),
                (loc == false)
                    ? Container(
                        width: 300.0,
                        height: 100.0,
                        alignment: Alignment.center,
                        child: RaisedButton.icon(
                          label: Text(
                            "Use Current Location",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Poppins-Regular"),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: Colors.black,
                          onPressed: getUserLocation,
                          icon: Icon(
                            Icons.my_location,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Column(children: [circularProgress(), Text("")]),
                GestureDetector(
                  onTap: () {
                    if (mob.text == "" ||
                        locationController.text == "" ||
                        locationController2.text == "" ||
                        locationController3.text == "" ||
                        locationController4.text == "" ||
                        locationController5.text == "")
                      fun1();
                    else
                      submit();
                  },
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ignore: missing_return
Color _getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
}
