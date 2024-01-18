

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/common_functions.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../../model/styleapp_data.dart';
import '../add_service.dart';

class SyncCustomersPage extends StatefulWidget {
  const SyncCustomersPage({Key? key}) : super(key: key);

  @override
  State<SyncCustomersPage> createState() => _SyncCustomersPageState();
}

class _SyncCustomersPageState extends State<SyncCustomersPage> {
  String customerId = "";
  List displayedContacts = [];
  List newContacts = [];
  TextEditingController searchController = TextEditingController();

  void defaultInitialization () async{

    Iterable<Contact>? contacts = Provider.of<StyleProvider>(context, listen: false).contacts;



   newContacts = contacts!.where((contact) =>
    contact.phones?.isNotEmpty == true  )
        //&&
        // Where the length of the contact doesnt exceed 13 character
        // contact.phones!.first.value!.length > 13)
   // Where the name and the phone number are not the same
       .where((contact) => contact.displayName != contact.phones?.first?.value)

       .toList();
    displayedContacts = newContacts;
   // print("HERE ARE THE CONTACTS $newContacts");
    setState(() {
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: kAppPinkColor,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Scaffold(
        appBar: AppBar(
          foregroundColor: kPureWhiteColor,
          title: Text("Select Customer and Add", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
          centerTitle: true,
          backgroundColor: kAppPinkColor,
          automaticallyImplyLeading: true,
          elevation: 0,
        ),

        body:
        Column(

          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    displayedContacts = newContacts
                        .where((contact) => contact.displayName!.toLowerCase()
                        .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: displayedContacts.length,
                //newContacts.length,
                itemBuilder: (BuildContext context, int index) {
                  Contact info = displayedContacts[index];
                  // Contact info = newContacts[index];
                  return ListTile(
                    title: Text(info.displayName ?? 'N/A'),
                    trailing: Image.asset("images/new_logo.png",height: 30,),
                    subtitle: Text(info.phones![0].value ?? 'N/A'),
                    //Text(info.phones?.first?.value ?? 'N/A'),
                    onTap: () async{
                      // _showContactDetails(info);
                      final prefs = await SharedPreferences.getInstance();

                      final initials = prefs.getString(kBusinessNameConstant)?.split(' ')
                          .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
                          .join('');
                      customerId = 'customer${initials}${uuid.v1().split("-")[0]}';
                      showDialog(context: context, builder: (BuildContext context){
                        return
                          CupertinoAlertDialog(
                            title: Text('Add ${info.displayName ?? 'N/A'}?'),
                            content: Column(
                              children: [
                                Text("Are you sure you want to add ${info.displayName ?? 'N/A'} : ${info.phones![0].value ?? 'N/A'}", style: kNormalTextStyle.copyWith(color: kBlack),),

                              ],
                            ),
                            actions: [

                              CupertinoDialogAction(isDestructiveAction: true,
                                  onPressed: (){
                                    // _btnController.reset();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel')),
                              CupertinoDialogAction(isDefaultAction: true,
                                  onPressed: (){
                                    // _btnController.reset();

                                    CommonFunctions().addCustomer(info.displayName ?? 'N/A', info.phones![0].value ?? 'N/A',context,customerId );

                                  },
                                  child: const Text('Add Contact')),

                            ],
                          );
                      });


                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
