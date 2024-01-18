import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/screens/products_pages/update_stock.dart';

import '../../Utilities/InputFieldWidget.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/stock_items.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/basket_items.dart';
import 'products_upload.dart';

class ProductsSearchPage extends StatefulWidget {
  static String id = "search_product";
  @override
  _ProductsSearchPageState createState() => _ProductsSearchPageState();

}

class _ProductsSearchPageState extends State<ProductsSearchPage> {
  late Stream<QuerySnapshot> _customerStream;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Stock> selectedStocks = [];

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
        .where('saleable', isEqualTo: true)
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
        .where('saleable', isEqualTo: true)
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
                          child: Text('No items found.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var customer = snapshot.data!.docs[index];
                          var name = customer['name'];
                          var amount = customer['amount'];
                          var description = customer['description'];
                          var tracking = customer['tracking'];
                          var minimum = customer['minimum'];
                          var instockQuantity = customer['quantity'];


                          return GestureDetector(
                            onTap: () {

                              description = description;
                              amount = amount.toDouble();
                              double quantity = 1;

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(


                                      content: Container(
                                        height: 350,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InputFieldWidget(readOnly: true,hintText: "", controller: name, onTypingFunction: (value){}, keyboardType: TextInputType.text, labelText: "Name 🔒"),
                                            InputFieldWidget(readOnly: false,hintText: "", controller: description, onTypingFunction: (value){description = value;}, keyboardType: TextInputType.text, labelText: "Description"),
                                            InputFieldWidget(readOnly: false,hintText: "", controller: quantity.toStringAsFixed(0), onTypingFunction: (value){quantity = double.parse(value); }, keyboardType: TextInputType.number, labelText: "Quantity"),
                                            InputFieldWidget(readOnly: false,hintText: "", controller: amount.toString(), onTypingFunction: (value){amount = double.parse(value);}, keyboardType: TextInputType.number, labelText: "Price"),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [

                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);

                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    backgroundColor: kFontGreyColor,
                                                  ),
                                                  child: Text('Cancel', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {


                                                    if (tracking == true) {
                                                      if(quantity <= instockQuantity){
                                                        Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(name:  name, quantity: quantity, amount: amount, details: description, tracking: tracking));
                                                        Provider.of<StyleProvider>(context, listen: false).addSelectedStockItems(Stock(name: name, id: customer.id, restock: quantity, price: amount/1.0));
                                                        Navigator.pop(context);
                                                      }
                                                      else {
                                                        Navigator.pop(context);
                                                        showDialog(context: context, builder: (BuildContext context){
                                                          return
                                                            CupertinoAlertDialog(
                                                              title: const Text('Quantity Too High'),
                                                              content: Text("The quantity available for ${name} is ${instockQuantity}! You have tried to sell ${quantity} units!", style: kNormalTextStyle.copyWith(color: kBlack),),
                                                              actions: [

                                                                CupertinoDialogAction(isDestructiveAction: true,
                                                                    onPressed: (){
                                                                      // _btnController.reset();
                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: const Text('Cancel')),
                                                                CupertinoDialogAction(isDefaultAction: true,
                                                                    onPressed: ()async{
                                                                      final prefs = await SharedPreferences.getInstance();
                                                                      Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));

                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context);
                                                                      Navigator.pushNamed(context, UpdateStockPage.id);
                                                                    },
                                                                    child: const Text('Update Stock')),


                                                              ],
                                                            );
                                                        });
                                                      }

                                                    } else {
                                                      Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(name:  name, quantity: quantity, amount: amount, details: description, tracking: tracking));
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    }
                                                    print("THIS IS AT POS STAGE $selectedStocks");


                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    backgroundColor: kCustomColorPink,
                                                  ),
                                                  child: Text('Add Product', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                                                ),
                                              ],
                                            ),


                                            // Text('Price: \$100'),
                                            // SizedBox(height: 10),
                                            // Text('Amount: 5'),
                                          ],
                                        ),
                                      ),
                                      // actions: [
                                      //   TextButton(
                                      //     onPressed: () {
                                      //       Navigator.of(context).pop();
                                      //     },
                                      //     child: Text('Close'),
                                      //   ),
                                      // ],
                                    );});
                            },
                            // onTap: (){
                            //   Navigator.pop(context);
                            //   Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(name:  name, quantity: 1, amount: amount, details: name, tracking: tracking));
                            //
                            //
                            //
                            //   // Provider.of<StyleProvider>(context, listen:false).setCustomerName(name, amount, id);
                            //
                            //
                            // },
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text('${CommonFunctions().formatter.format(amount)}'),
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
                      var id = customer['id'];
                      var amount = customer['amount'];
                      var description = customer['description'];
                      var tracking = customer['tracking'];
                      var minimum = customer['minimum'];
                      var instockQuantity = customer['quantity'];


                      return GestureDetector(
                        onTap: () {

                          description = description;
                          amount = amount.toDouble();
                          double quantity = 1;

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(


                                  content: Container(
                                    height: 350,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InputFieldWidget(readOnly: true,hintText: "", controller: name, onTypingFunction: (value){}, keyboardType: TextInputType.text, labelText: "Name 🔒"),
                                        InputFieldWidget(readOnly: false,hintText: "", controller: description, onTypingFunction: (value){description = value;}, keyboardType: TextInputType.text, labelText: "Description"),
                                        InputFieldWidget(readOnly: false,hintText: "", controller: quantity.toStringAsFixed(0), onTypingFunction: (value){quantity = double.parse(value); }, keyboardType: TextInputType.number, labelText: "Quantity"),
                                        InputFieldWidget(readOnly: false,hintText: "", controller: amount.toString(), onTypingFunction: (value){amount = double.parse(value);}, keyboardType: TextInputType.number, labelText: "Price"),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [

                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);

                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                backgroundColor: kFontGreyColor,
                                              ),
                                              child: Text('Cancel', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {


                                                if (tracking == true) {
                                                  if(quantity <= instockQuantity){
                                                    Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(name:  name, quantity: quantity, amount: amount, details: description, tracking: tracking));
                                                    Provider.of<StyleProvider>(context, listen: false).addSelectedStockItems(Stock(name: name, id: id, restock: quantity, price: amount/1.0));
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  }
                                                  else {
                                                    Navigator.pop(context);
                                                    showDialog(context: context, builder: (BuildContext context){
                                                      return
                                                        CupertinoAlertDialog(
                                                          title: const Text('Quantity Too High'),
                                                          content: Text("The quantity available for ${name} is ${instockQuantity}! You have tried to sell ${quantity} units!", style: kNormalTextStyle.copyWith(color: kBlack),),
                                                          actions: [

                                                            CupertinoDialogAction(isDestructiveAction: true,
                                                                onPressed: (){
                                                                  // _btnController.reset();

                                                                  Navigator.pop(context);
                                                                },
                                                                child: const Text('Cancel')),
                                                            CupertinoDialogAction(isDefaultAction: true,
                                                                onPressed: ()async{
                                                                  final prefs = await SharedPreferences.getInstance();
                                                                  Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));

                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  Navigator.pushNamed(context, UpdateStockPage.id);
                                                                },
                                                                child: const Text('Update Stock')),


                                                          ],
                                                        );
                                                    });
                                                  }

                                                } else {
                                                  Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(name:  name, quantity: quantity, amount: amount, details: description, tracking: tracking));
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                }
                                                print("THIS IS AT POS STAGE $selectedStocks");


                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                backgroundColor: kCustomColorPink,
                                              ),
                                              child: Text('Add Product', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                                            ),
                                          ],
                                        ),


                                        // Text('Price: \$100'),
                                        // SizedBox(height: 10),
                                        // Text('Amount: 5'),
                                      ],
                                    ),
                                  ),
                                  // actions: [
                                  //   TextButton(
                                  //     onPressed: () {
                                  //       Navigator.of(context).pop();
                                  //     },
                                  //     child: Text('Close'),
                                  //   ),
                                  // ],
                                );});
                        },
                        child: ListTile(
                          title: Text(name),
                          subtitle: Text(CommonFunctions().formatter.format(amount)),
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
                        Navigator.pop(context);
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return  Scaffold(
                                  appBar: AppBar(
                                    automaticallyImplyLeading: false,
                                    backgroundColor: kBlack,
                                  ),
                                  body: ProductUpload());
                            });

                      },
                      child: Lottie.asset('images/round.json', height: 50),
                    ),
                    Text("Create Product",style: kNormalTextStyle.copyWith(color: kBlueDarkColor, fontSize: 10),)
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
