import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';

import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import 'product_edit_page.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/basket_items.dart';

class ProductsDetailedSearchPage extends StatefulWidget {
  static String id = "search_product_details";
  @override
  _ProductsDetailedSearchPageState createState() => _ProductsDetailedSearchPageState();

}

class _ProductsDetailedSearchPageState extends State<ProductsDetailedSearchPage> {
  late Stream<QuerySnapshot> _customerStream;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    var storeId = prefs.getString(kStoreIdConstant);

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
        .collection('stores')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThan: searchQuery + 'z')
        .get()
        .then((querySnapshot) {
      setState(() {
        print(Provider.of<BeauticianData>(context, listen: false).storeId);
        _searchResults = querySnapshot.docs.map((doc) =>
        // doc.data()).toList();
        doc.data()).where((data) => data['storeId'] == Provider.of<BeauticianData>(context, listen: false).storeId).toList();
        print(_searchResults);
      });

    }).catchError((error) {
      print('Error searching for customers: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    defaultInitialization();
    _customerStream = FirebaseFirestore.instance.collection('stores').where('active', isEqualTo: true)
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
                      child: Text('No items found.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var customer = snapshot.data!.docs[index];
                      var name = customer['name'];
                      var amount = customer['amount'];
                      var quantity = customer['quantity'];
                      var description = customer['description'];
                      var id = customer['id'];
                      var image = customer['image'];
                      var saleable = customer['saleable'];
                      var tracking = customer['tracking'];
                      var minimum = customer['minimum'];
                      var barcode = customer['barcode'];
                      var unit = customer['unit'];
                      var ignore = customer['ignore'];

                      return GestureDetector(
                        onTap: (){
                          Provider.of<BeauticianData>(context, listen: false).changeItemDetails( name, quantity,  description, minimum, id,  amount, image, tracking, saleable, barcode, unit, ignore);
                          Navigator.pop(context);
                          Navigator.pushNamed(context, ProductEditPage.id);

                          // Provider.of<StyleProvider>(context, listen:false).setCustomerName(name, amount, id);


                        },
                        child: ListTile(
                          title: Text(name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,

                            children: [
                              Text('Ugx ${CommonFunctions().formatter.format(amount)}'),
                              tracking == true ? Text('Qty: $quantity') : Container(),
                              kLargeHeightSpacing
                            ],
                          ),

                        ),
                      );
                    },
                  );
                },
              ):
              // Text("Something exists")
              ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var customer = _searchResults[index];
                  var name = customer['name'];
                  var amount = customer['amount'];
                  var quantity = customer['quantity'];
                  var description = customer['description'];
                  var id = customer['id'];
                  var image = customer['image'];
                  var saleable = customer['saleable'];
                  var tracking = customer['tracking'];
                  var minimum = customer['minimum'];
                  var barcode = customer['barcode'];
                  var unit = customer['unit'];
                  var ignore = customer['ignore'];


                  return GestureDetector(
                    onTap: (){

                      // Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(name:  name, quantity: 1, amount: amount, details: name));
                      Provider.of<BeauticianData>(context, listen: false).changeItemDetails( name, quantity,  description, minimum, id,  amount, image, tracking, saleable, barcode, unit, ignore);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ProductEditPage.id);


                    },
                    child: ListTile(
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          Text('Ugx ${CommonFunctions().formatter.format(amount)}'),
                          tracking == true ? Text('Qty: $quantity') : Container(),
                          kLargeHeightSpacing
                        ],
                      ),

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
