import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String sellerId;
  final String email;
  final String mobile;
  final String displayName;
  final String door;
  final String street;
  final String locality;
  final String city;
  final String zip;
  final Timestamp timestamp;

  User(
      {this.id,
      this.sellerId,
      this.email,
      this.mobile,
      this.displayName,
      this.door,
      this.street,
      this.locality,
      this.city,
      this.zip,
      this.timestamp});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        sellerId: doc['sellerId'],
        email: doc['email'],
        mobile: doc['mobile'],
        displayName: doc['displayName'],
        door: doc['door'],
        street: doc['street'],
        locality: doc['locality'],
        city: doc['city'],
        zip: doc['zip'],
        timestamp: doc['timestamp']);
  }
}
