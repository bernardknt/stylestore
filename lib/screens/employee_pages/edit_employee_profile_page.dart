import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/controllers/responsive/responsive_page.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../controllers/home_page_controllers/home_control_page_web.dart';
import '../../model/common_functions.dart';
import '../../widgets/rounded_icon_widget.dart';
import '../../widgets/text_form.dart';



class EditProfilePage extends StatefulWidget {
  static String id = "edit_profile_page";
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  UploadTask? uploadTask;
  String? selectedDepartment;


  String? selectedFluency;
  String gender = '';
  DateTime? selectedBirthday;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  DateTime? selectedEducationDate;
  String maritalStatus = '';
  String serviceId = "mcfbm${Uuid().v4().split(" - ")[0]}";
  String? _selectedSupervisor;


  File? image;
  var imageUploaded = false;
  Future pickImage(ImageSource source)async{
    try {
      final image =
      //await ImagePicker().pickImage(source: source);
      await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null){
        return ;
      }else {
        // final blob = await pickedFileToBlob(image as PickedFile);
        File file = File(image.path);

        // final compressedImage = await CommonFunctions().compressImage(File(image.path));
        uploadFile(file, serviceId);

        setState(() {
          imageUploaded = true;
          this.image = file;
        });
      }
    } on PlatformException catch (e) {
      print('Failed to pick image $e');

    }
  }
  _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedBirthday) {
      setState(() {
        selectedBirthday = picked;
      });
    }
  }

  Future<void> uploadFile(File file, String fileName) async {
    var businessProvider = Provider.of<BeauticianData>(context, listen: false);
    try {
      if (kIsWeb) {
        PickedFile pickedFile = PickedFile(file.path);
        final blob = await pickedFileToBlob(pickedFile);
        uploadTask = storage.ref('employees/$fileName').putBlob(blob);
      } else {
        uploadTask = storage.ref('employees/$fileName').putFile(file);
      }
      final snapshot = await uploadTask!.whenComplete(() {

      });
      final urlDownload = await snapshot.ref.getDownloadURL();
      print(urlDownload); // this is the downloadable url for the image uploaded
      // show a snackbar to the user to show that the upload was successful
      CommonFunctions().showSuccessNotification('New Image for ${businessProvider.employeeInformation?.fullNames} Uploaded Successfully', context);
      putStoreProfilePicture(businessProvider.employeeInformation?.documentId, urlDownload);
    } catch(e){
      print(e);
    }
  }

  Future<html.Blob> pickedFileToBlob(PickedFile pickedFile) async {
    final data = await pickedFile.readAsBytes();
    final blob = html.Blob([data]);
    return blob;
  }

  CollectionReference storeLocation = FirebaseFirestore.instance.collection('employees');
  Future<void> putStoreProfilePicture(userId, image) async{
    return storeLocation.doc(userId)
        .update({
      'picture': image,
    })
        .then((value) {
    })
        .catchError((error) => print("Failed to add Item: $error"));
  }



  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController jobPositionController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController kinNumberController = TextEditingController();
  final TextEditingController kinController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController nationaldController = TextEditingController();

  Container _buildDivider(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[300],

    );}


  void defaultInitialization(){

    var broadcastProvider = Provider.of<BeauticianData>(context, listen: false);
    gender = broadcastProvider.employeeInformation?.gender ?? "Female";
    selectedBirthday = broadcastProvider.employeeInformation?.birthday ?? DateTime.now();
    selectedDepartment = broadcastProvider.employeeInformation?.department ?? "Administration";
    fullNameController.text = broadcastProvider.employeeInformation?.fullNames ?? "";
    positionController.text = broadcastProvider.employeeInformation?.position ?? "";
    nationalityController.text = broadcastProvider.employeeInformation?.nationality ?? "";
    phoneController.text = broadcastProvider.employeeInformation?.phone ?? "";
    addressController.text = broadcastProvider.employeeInformation?.address ?? "";
    kinNumberController.text = broadcastProvider.employeeInformation?.kinNumber ?? "";
    kinController.text = broadcastProvider.employeeInformation?.kin ?? "";
    emailController.text = broadcastProvider.employeeInformation?.email ?? "";
    tinController.text = broadcastProvider.employeeInformation?.tin ?? "";
    maritalStatus = broadcastProvider.employeeInformation?.maritalStatus ?? "";
    nationaldController.text = broadcastProvider.employeeInformation?.nationalIdNumber ?? "";
    setState(() {

    });
  }




  @override
  void initState() {
    super.initState();
    defaultInitialization();
  }

  @override
  Widget build(BuildContext context) {
    var businessData= Provider.of<BeauticianData>(context, listen: false);
    var broadcastDataListen= Provider.of<BeauticianData>(context, listen: true);


    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Edit Profile for ${Provider.of<BeauticianData>(context, listen: false).employeeInformation!.fullNames}'),
              kMediumWidthSpacing,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: kFontGreyColor,
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: Text('Delete Profile', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                onPressed: () {
                  // show a dialog to confirm deletion
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Profile'),
                      content: Text('Are you sure you want to delete this profile?\nThis action cannot be undone.'),
                      actions: [
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            _deleteProfile();
                          },
                        ),
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Set the floating action button that is extended to the bottom right of the screen
        floatingActionButton:
        FloatingActionButton.extended(
            backgroundColor: kGreenThemeColor,
            onPressed: (){
              _saveProfile();
            },
            label: Text("Save Profile", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Form(
            key: _formKey,
            child: Center(
                child: Container(
                    color:kBackgroundGreyColor,

                    width: 650,

                    child: ListView(
                        padding: EdgeInsets.all(16.0),
                        children: [
                          GestureDetector(
                              onTap: () {
                                // Add code to pick image from gallery here
                                pickImage(ImageSource.gallery);

                              },
                              child: imageUploaded == false?
                              Stack(

                                children: [
                                  RoundImageRing(networkImageToUse: businessData.employeeInformation!.picture, outsideRingColor: kPureWhiteColor),
                                  Positioned(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('Change Image', style: kNormalTextStyle.copyWith(color: kGreenThemeColor),),
                                      Icon(Icons.add_a_photo, color: kGreenThemeColor,),
                                    ],
                                  ), top: 0, right: 10,)
                                ],
                              ):
                              //Image.file(image!, height: 180,)
                              kIsWeb? Image.network(image!.path, height: 180,):Image.file(image!, height: 180,)
                          ),
                          kMediumWidthSpacing,
                          TextForm('Full Names', fullNameController),
                          Text("Birthday", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          GestureDetector(
                              onTap: (){
                                _selectBirthday(context);
                              },
                              child: Text(selectedBirthday != null ? DateFormat('dd, MMMM, yyyy').format(selectedBirthday!) : 'Click to Set Birthday',style: TextStyle(fontSize: 14, color: kFontGreyColor))),

                          Text("Gender", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          kLargeHeightSpacing,
                          Row(
                            children: [
                              Radio(
                                value: 'Male',
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value.toString();
                                  });
                                },
                              ),
                              Text('Male'),
                              Radio(
                                value: 'Female',
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value.toString();
                                  });
                                },
                              ),
                              Text('Female'),
                            ],
                          ),
                          kLargeHeightSpacing,
                          Text("Department", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          // TextForm('Department', departmentController),
                          DropdownButton<String>(
                            value: selectedDepartment, // The currently selected department
                            items: departments.map((department) => DropdownMenuItem(
                              value: department,
                              child: Text(department),
                            )).toList(),
                            onChanged: (newDepartment) => setState(() => selectedDepartment = newDepartment), // Update the selected department when a new one is chosen
                            hint: Text('Select Department'), // Placeholder text before a department is selected
                          ),

                          TextForm('Position', positionController),
                          TextForm('Nationality', nationalityController),
                          TextForm('Phone Contacts', phoneController),
                          TextForm('Email', emailController),
                          TextForm('Physical Address', addressController),
                          TextForm('Next of Kin', kinController),
                          TextForm('Next of Kin Number', kinNumberController),
                          Text(
                            'Marital Status',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          kLargeHeightSpacing,
                          Row(
                            children: [
                              Radio(
                                value: 'Single',
                                groupValue: maritalStatus,
                                onChanged: (value) {
                                  setState(() {
                                    maritalStatus = value.toString();
                                  });
                                },
                              ),
                              Text('Single'),
                              Radio(
                                value: 'Married',
                                groupValue: maritalStatus,
                                onChanged: (value) {
                                  setState(() {
                                    maritalStatus = value.toString();
                                  });
                                },
                              ),
                              Text('Married'),
                            ],
                          ),
                          TextForm('TIN', tinController),
                          TextForm('National ID', nationaldController),
                        ])
                )
            )
        )
    );
  }

  void _deleteProfile() {
    // Add code for loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    _firestore.collection('employees').doc( Provider.of<BeauticianData>(context, listen: false).employeeInformation?.documentId).delete().whenComplete(() {
      Navigator.pop(context);
      Navigator.pushNamed(context, SuperResponsiveLayout.id);
    });
  }
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();



      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing by tapping outside
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      _firestore.collection('employees').doc( Provider.of<BeauticianData>(context, listen: false).employeeInformation?.documentId).update({
        'name': fullNameController.text,
        'role': positionController.text,
        'nationality': nationalityController.text,
        'phoneNumber': phoneController.text,
        'address': addressController.text,
        'tin': tinController.text,
        'email': emailController.text,
        'nextOfKin': kinController.text,
        'nextOfKinNumber': kinNumberController.text,
        'department': selectedDepartment,
        'gender': gender,
        'dateOfBirth': selectedBirthday,
        'maritalStatus': maritalStatus,
        'nationalIdNumber': nationaldController.text,
      }
      ).whenComplete(() {
        Navigator.pop(context);
        Navigator.pushNamed(context, SuperResponsiveLayout.id);
      });
    }

  }

}