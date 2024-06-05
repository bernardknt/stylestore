
import 'package:cloud_firestore/cloud_firestore.dart';

class AllEmployeeData {
  final String documentId;
  final String fullNames;
  final String gender;
  final String position;
  // final String nationality;
  final String phone;
  final String address;
  final String token;
  late final String department;
  final String tin;
  final String maritalStatus;
  final String picture;
  final String email;
  final String kin;
  final String kinNumber;
  final String nationalIdNumber;
  final DateTime birthday;
  final String code;
  final String permissions;
  final Map<String, dynamic> loggedIn;

  AllEmployeeData({
    required this.birthday,
    required this.picture,
    required this.fullNames,
    required this.gender,
    required this.position,
    // required this.nationality,
    required this.phone,
    required this.address,
    required this.department,
    required this.tin,
    required this.email,
    required this.kin,
    required this.kinNumber,
    required this.maritalStatus,
    required this.loggedIn,
    required this.documentId,
    required this.nationalIdNumber,
    required this.code,
    required this.token,
    required this.permissions,

  });

  factory AllEmployeeData.fromFirestore(DocumentSnapshot doc) {
    return AllEmployeeData(
      documentId: doc.id,
      fullNames: doc['name'] ?? '',
      gender: doc['gender'] ?? '',
      position: doc['role'] ?? '',
      // nationality: doc['nationality'] ?? '',
      phone: doc['phoneNumber'] ?? '',
      address: doc['address'] ?? '',
      department: doc['department'] ?? '',
      tin: doc['tin'] ?? '',
      loggedIn: doc['signedIn'],
      picture: doc['picture'] ??'',
      kin: doc['nextOfKin'] ??'',
      kinNumber: doc['nextOfKinNumber'] ??'',
      email: doc['email'] ??'',
      birthday:doc['dateOfBirth'].toDate(),
      nationalIdNumber:doc['nationalIdNumber'] ??'',
      code:doc['code'] ??'',
      token:doc['token'] ??'',
      maritalStatus: doc['maritalStatus'] ??'Single',
      permissions: doc['permissions'] ??'{}',

    );
  }
}
