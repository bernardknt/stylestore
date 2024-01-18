import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class BusinessSignup extends StatefulWidget {

  static String id = 'Business_signup';
  @override
  _BusinessSignupState createState() => _BusinessSignupState();
}

class _BusinessSignupState extends State<BusinessSignup> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  String name = '';
  String phoneNumber = '';
  String description = '';
  String services = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Upload the form data to Firebase collection
      try {
        await FirebaseFirestore.instance.collection('medics').add({
          'name': name,
          'phoneNumber': phoneNumber,
          'description': description,
          'services': services,
        });
        // Show a success message or navigate to the next screen
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Form submitted successfully!'),
              actions: <Widget>[
                IconButton(
                  icon: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } catch (error) {
        // Handle the error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred while submitting the form.'),
              actions: <Widget>[
                IconButton(

                  onPressed: () {
                    Navigator.of(context).pop();
                  }, icon: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                name: 'name',
                decoration: InputDecoration(labelText: 'Name'),
                // validator: FormBuilder,
                onSaved: (value) {
                  name = value!;
                },
              ),
              FormBuilderTextField(
                name: 'phoneNumber',
                decoration: InputDecoration(labelText: 'Phone Number'),
                // validator: FormBuilderValidators.required(context),
                onSaved: (value) {
                  phoneNumber = value!;
                },
              ),
              FormBuilderTextField(
                name: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                // validator: FormBuilderValidators.required(context),
                onSaved: (value) {
                  description = value!;
                },
              ),
              FormBuilderTextField(
                name: 'services',
                decoration: InputDecoration(labelText: 'Services'),
                // validator: FormBuilderValidators.required(context),
                onSaved: (value) {
                  services = value!;
                },
              ),
              SizedBox(height: 16.0),
              IconButton(
                icon: Text('Submit'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
