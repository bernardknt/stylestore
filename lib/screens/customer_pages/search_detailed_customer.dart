import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';

import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';

import '../../widgets/customer_content.dart';
import '../../widgets/modalButton.dart';
import 'customer_edit_page.dart';
import 'customer_transactions.dart';

class CustomerDetailedSearchPage extends StatefulWidget {
  static String id = "search_customer_detailed";
  @override
  _CustomerDetailedSearchPageState createState() => _CustomerDetailedSearchPageState();

}

class _CustomerDetailedSearchPageState extends State<CustomerDetailedSearchPage> {
  late Stream<QuerySnapshot> _customerStream;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    var storeId = prefs.getString(kStoreIdConstant);

  }

  String removeCurlyBraces(String jsonString) {
    return jsonString.replaceAll('{', '').replaceAll('}', '');
  }

  void _performSearch(String searchQuery) {
    if (searchQuery.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _searchResults = [];
    });

    FirebaseFirestore.instance
        .collection('customers')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThan: searchQuery + 'z')
        .get()
        .then((querySnapshot) {
      setState(() {
        print(Provider.of<BeauticianData>(context, listen: false).storeId);
        _searchResults = querySnapshot.docs.map((doc) =>
        doc.data()).where((data) => data['storeId'] == Provider.of<BeauticianData>(context, listen: false).storeId).toList();
      });

    }).catchError((error) {
      print('Error searching for customers: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    defaultInitialization();
    _customerStream = FirebaseFirestore.instance.collection('customers').where('active', isEqualTo: true)
        .where('storeId', isEqualTo:Provider.of<BeauticianData>(context, listen: false).storeId)
        .orderBy('name',descending: false).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPureWhiteColor,
        // title: Text('Customer List'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _performSearch(value);
                  // Implement search functionality here
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: _searchResults.isEmpty
                  ?
              StreamBuilder<QuerySnapshot>(
                stream: _customerStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No customers found.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var customer = snapshot.data!.docs[index];
                      var name = customer['name'];
                      var phoneNumber = customer['phoneNumber'];
                      var id = customer['id'];
                      var info = customer['info'];
                      var items = customer['options'];
                      var photo = customer['image'];
                      var location = customer['location'];

                      return GestureDetector(
                        onTap: ()async{
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  color: Color(0xFF292929).withOpacity(0.6),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: kPureWhiteColor,
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30) )
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20.0, bottom: 50, left: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children:
                                        [
                                          buildButton(context, 'Edit ${name}', Iconsax.pen_add,
                                                  () async {

                                                Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(name, phoneNumber, info, items.toString().replaceAll('{', '').replaceAll('}', ''),
                                                   photo, location, id);
                                                Navigator.pop(context);
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=> CustomerEditPage()));


                                              }
                                          ),
                                          SizedBox(height: 16.0),
                                          buildButton(context, 'Buying History of $name', Iconsax.money_send,  () async {
                                            Navigator.pop(context);

                                            // Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(customerNameList[index], phoneNumberList[index], infoList[index], items[index].toString().replaceAll('{', '').replaceAll('}', ''),
                                            //     photoImage[index], locationList[index], id[index]);
                                            Provider.of<BeauticianData>(context, listen: false).setClientName(name,id);
                                            Navigator.pushNamed(context, CustomerTransactionsProducts.id);

                                          } ),
                                          items.length != 0 ?buildButton(context, '$name Extra Details', Iconsax.personalcard,  () async {
                                            Navigator.pop(context);
                                            showDialog(context: context, builder: (BuildContext context){
                                              return
                                                GestureDetector(
                                                  onTap: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: Stack(
                                                      children: [

                                                        CupertinoAlertDialog(
                                                          title:  Column(
                                                            children: [
                                                              Text("$name"),
                                                              Text("Key Details", style:TextStyle(fontWeight: FontWeight.normal, fontSize: 12),),

                                                            ],
                                                          ),
                                                          content: Container(

                                                            width: 100,
                                                            height: 300,
                                                            // color: Colors.teal,
                                                            child:
                                                            ListView.builder(

                                                                shrinkWrap: true,
                                                                itemCount: items.keys.toList().length,
                                                                itemBuilder: (context, i){
                                                                  return CustomerContentsWidget(
                                                                      orderIndex: i + 1,
                                                                      optionName: items.keys.toList()[i],
                                                                      optionValue: items.values.toList()[i]
                                                                  );

                                                                }),

                                                          ),



                                                          actions: [CupertinoDialogAction(isDestructiveAction: true,
                                                              onPressed: (){
                                                                // _btnController.reset();
                                                                Navigator.pop(context);
                                                              },
                                                              child: const Text('Cancel'))],
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                );
                                            });

                                          } ): Container(),


                                        ],
                                      ),
                                    ),
                                  ),
                                ); });

                        },
                        child:
                        Stack(
                          children: [
                            ListTile(
                              //title: Text(itemName[index]),

                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,),
                                  Text('${phoneNumber}',),
                                  Text('Note: ${info}', ),
                                  Text('Prefs: ${removeCurlyBraces(items.toString())}', ),
                                  kLargeHeightSpacing

                                ],
                              ),),


                          ],
                        ),
                        // ListTile(
                        //   title: Text(name),
                        //   subtitle: Text(phoneNumber),
                        // ),
                      );
                    },
                  );
                },
              ):
              // : Text("Something exists")
              ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var customer = _searchResults[index];

                  var name = customer['name'];
                  var phoneNumber = customer['phoneNumber'];
                  var id = customer['id'];
                  var info = customer['info'];
                  var items = customer['options'];
                  var photo = customer['image'];
                  var location = customer['location'];

                  return GestureDetector(
                    onTap: ()async{
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              color: Color(0xFF292929).withOpacity(0.6),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: kPureWhiteColor,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30) )
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0, bottom: 50, left: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                    [
                                      buildButton(context, 'Edit ${name}', Iconsax.pen_add,
                                              () async {

                                            Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(name, phoneNumber, info, items.toString().replaceAll('{', '').replaceAll('}', ''),
                                                photo, location, id);
                                            Navigator.pop(context);
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> CustomerEditPage()));


                                          }
                                      ),
                                      SizedBox(height: 16.0),
                                      buildButton(context, 'Buying History of $name', Iconsax.money_send,  () async {
                                        Navigator.pop(context);

                                        // Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(customerNameList[index], phoneNumberList[index], infoList[index], items[index].toString().replaceAll('{', '').replaceAll('}', ''),
                                        //     photoImage[index], locationList[index], id[index]);
                                        Provider.of<BeauticianData>(context, listen: false).setClientName(name,id);
                                        Navigator.pushNamed(context, CustomerTransactionsProducts.id);

                                      } ),
                                      items.length != 0 ?buildButton(context, '$name Extra Details', Iconsax.personalcard,  () async {
                                        Navigator.pop(context);
                                        showDialog(context: context, builder: (BuildContext context){
                                          return
                                            GestureDetector(
                                              onTap: (){
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                color: Colors.transparent,
                                                child: Stack(
                                                  children: [

                                                    CupertinoAlertDialog(
                                                      title:  Column(
                                                        children: [
                                                          Text("$name"),
                                                          Text("Key Details", style:TextStyle(fontWeight: FontWeight.normal, fontSize: 12),),

                                                        ],
                                                      ),
                                                      content: Container(

                                                        width: 100,
                                                        height: 300,
                                                        // color: Colors.teal,
                                                        child:
                                                        ListView.builder(

                                                            shrinkWrap: true,
                                                            itemCount: items.keys.toList().length,
                                                            itemBuilder: (context, i){
                                                              return CustomerContentsWidget(
                                                                  orderIndex: i + 1,
                                                                  optionName: items.keys.toList()[i],
                                                                  optionValue: items.values.toList()[i]
                                                              );

                                                            }),

                                                      ),



                                                      actions: [CupertinoDialogAction(isDestructiveAction: true,
                                                          onPressed: (){
                                                            // _btnController.reset();
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Text('Cancel'))],
                                                    ),

                                                  ],
                                                ),
                                              ),
                                            );
                                        });

                                      } ): Container(),


                                    ],
                                  ),
                                ),
                              ),
                            ); });

                    },
                    child:
                    Stack(
                      children: [
                        ListTile(
                          //title: Text(itemName[index]),

                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,),
                              Text('${phoneNumber}',),
                              Text('Note: ${info}', ),
                              Text('Prefs: ${removeCurlyBraces(items.toString())}', ),
                              kLargeHeightSpacing

                            ],
                          ),),


                      ],
                    ),
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
