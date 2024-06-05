import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';

import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../payment_pages/pos_summary.dart';
import 'add_customers_page.dart';

class CustomerSearchPage extends StatefulWidget {
  static String id = "search_customer";
  @override
  _CustomerSearchPageState createState() => _CustomerSearchPageState();

}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  late Stream<QuerySnapshot> _customerStream;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  var storeId = "";

  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant)!;
    setState(() {

    });

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
            // doc.data()).toList();
           doc.data()).where((data) => data['storeId'] == storeId).toList();
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
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPureWhiteColor,
        // title: Text('Customer List'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                          var location = customer['location'];
                          var id = customer['id'];

                          return GestureDetector(
                            onTap: (){

                              Provider.of<StyleProvider>(context, listen:false).setCustomerName(name, phoneNumber, id, location);
                              Navigator.pop(context);
                              if (MediaQuery.of(context).size.width < 600){
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return PosSummary(currency: Provider.of<StyleProvider>(context, listen: false).storeCurrency,);
                                    });

                              }

                            },
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text(phoneNumber),
                              // leading: Text("Great Man"),
                            ),
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
                      var location = customer['location'];

                      return GestureDetector(
                        onTap: (){
                          print("$name $phoneNumber");
                          Provider.of<StyleProvider>(context, listen:false).setCustomerName(name, phoneNumber, id, location);
                         Navigator.pop(context);

                          //Navigator.pop(context);


                        },
                        child: ListTile(
                          title: Text(name),
                          subtitle: Text(phoneNumber),

                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
                bottom: 50,
                right: 5,
                child: Column(
                  children: [
                    GestureDetector(

                      onTap: (){
                        // Navigator.pop(context);
                        showDialog(context: context, builder: (BuildContext context){
                          return
                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child:
                              Material(
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("ADD A NEW CUSTOMER", textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontSize:14,color: kPureWhiteColor, fontWeight: FontWeight.bold),),
                                    kLargeHeightSpacing,
                                    kLargeHeightSpacing,
                                    kLargeHeightSpacing,
                                    kLargeHeightSpacing,
                                    kLargeHeightSpacing,
                                    Center(child:

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                // Navigator.pop(context);
                                               CommonFunctions.syncContacts(context, 2);


                                              },
                                              child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: kAppPinkColor.withOpacity(1),
                                                  child: const Icon(Iconsax.cloud, color: kPureWhiteColor,size: 30,)),
                                            ),
                                            Text("Sync from Contacts", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),)
                                          ],
                                        ),
                                        kMediumWidthSpacing,
                                        kMediumWidthSpacing,
                                        kMediumWidthSpacing,
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, AddCustomersPage.id);
                                              },
                                              child: CircleAvatar(
                                                  backgroundColor: kCustomColor.withOpacity(1),

                                                  radius: 30,
                                                  child: const Icon(Iconsax.calculator, color: kBlack,size: 30,)),
                                            ),
                                            Text("Enter Manually", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),)
                                          ],
                                        ),

                                      ],
                                    )),

                                  ],
                                ),
                              ),
                            );
                        });


                      },
                      child: Container (
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: kAppPinkColor, 
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(child: Text("+", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 28),)),

                      )
                      //Lottie.asset('images/round.json', height: 50),
                    ),
                    Text("Create Customer",style: kNormalTextStyle.copyWith(color: kBlueDarkColor, fontSize: 10),)
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
