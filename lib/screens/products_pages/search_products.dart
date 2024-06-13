import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/products.dart';
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
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Stock> selectedStocks = [];
  List<Product> products = [];

  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    var storeId = prefs.getString(kStoreIdConstant);

    setState(() {
      products =
          Provider.of<BeauticianData>(context, listen: false).productItems;
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

    products.forEach((product) {
      if (product.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        setState(() {
          _searchResults.add({
            'name': product.name,
            'amount': product.amount,
            'description': product.description,
            'tracking': product.tracking,
            'minimum': product.minimum,
            'quantity': product.quantity,
            'id': product.id
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    defaultInitialization();
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
                      // SHOW A LIST OF ALL THE PRODUCTS
                      ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var customer = products[index];
                            var name = customer.name;
                            var id = customer.id;
                            var amount = customer.amount;
                            var description = customer.description;
                            var tracking = customer.tracking;
                            var instockQuantity = customer.quantity;

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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InputFieldWidget(
                                                  readOnly: true,
                                                  hintText: "",
                                                  controller: name,
                                                  onTypingFunction: (value) {},
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelText: "Name 🔒"),
                                              InputFieldWidget(
                                                  readOnly: false,
                                                  hintText: "",
                                                  controller: description,
                                                  onTypingFunction: (value) {
                                                    description = value;
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelText: "Description"),
                                              InputFieldWidget(
                                                  readOnly: false,
                                                  hintText: "",
                                                  controller: quantity
                                                      .toStringAsFixed(0),
                                                  onTypingFunction: (value) {
                                                    quantity =
                                                        double.parse(value);
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  labelText: "Quantity"),
                                              InputFieldWidget(
                                                  readOnly: false,
                                                  hintText: "",
                                                  controller: amount.toString(),
                                                  onTypingFunction: (value) {
                                                    amount =
                                                        double.parse(value);
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  labelText: "Price"),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      backgroundColor:
                                                          kFontGreyColor,
                                                    ),
                                                    child: Text(
                                                      'Cancel',
                                                      style: kNormalTextStyle
                                                          .copyWith(
                                                              color:
                                                                  kPureWhiteColor),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (tracking == true) {
                                                        if (quantity <=
                                                            instockQuantity) {
                                                          Provider.of<StyleProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .addToServiceBasket(BasketItem(
                                                                  name: name,
                                                                  quantity:
                                                                      quantity,
                                                                  amount:
                                                                      amount,
                                                                  details:
                                                                      description,
                                                                  tracking:
                                                                      tracking));
                                                          Provider.of<StyleProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .addSelectedStockItems(Stock(
                                                                  name: name,
                                                                  id: id,
                                                                  restock:
                                                                      quantity,
                                                                  price:
                                                                      amount /
                                                                          1.0));
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return CupertinoAlertDialog(
                                                                  title: const Text(
                                                                      'Quantity Too High'),
                                                                  content: Text(
                                                                    "The quantity available for ${name} is ${instockQuantity}! You have tried to sell ${quantity} units!",
                                                                    style: kNormalTextStyle
                                                                        .copyWith(
                                                                            color:
                                                                                kBlack),
                                                                  ),
                                                                  actions: [
                                                                    CupertinoDialogAction(
                                                                        isDestructiveAction:
                                                                            true,
                                                                        onPressed:
                                                                            () {
                                                                          // _btnController.reset();

                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            'Cancel')),
                                                                    CupertinoDialogAction(
                                                                        isDefaultAction:
                                                                            true,
                                                                        onPressed:
                                                                            () async {
                                                                          final prefs =
                                                                              await SharedPreferences.getInstance();
                                                                          Provider.of<BeauticianData>(context, listen: false)
                                                                              .setStoreId(prefs.getString(kStoreIdConstant));

                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              UpdateStockPage.id);
                                                                        },
                                                                        child: const Text(
                                                                            'Update Stock')),
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      } else {
                                                        Provider.of<StyleProvider>(
                                                                context,
                                                                listen: false)
                                                            .addToServiceBasket(
                                                                BasketItem(
                                                                    name: name,
                                                                    quantity:
                                                                        quantity,
                                                                    amount:
                                                                        amount,
                                                                    details:
                                                                        description,
                                                                    tracking:
                                                                        tracking));
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      }
                                                      print(
                                                          "THIS IS AT POS STAGE $selectedStocks");
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      backgroundColor:
                                                          kCustomColorPink,
                                                    ),
                                                    child: Text(
                                                      'Add Product',
                                                      style: kNormalTextStyle
                                                          .copyWith(
                                                              color:
                                                                  kPureWhiteColor),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Text('Price: \$100'),
                                              // SizedBox(height: 10),
                                              // Text('Amount: 5'),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child:
                                  productItemsCard(name: name, amount: amount),
                            );
                          },
                        )
                      :
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InputFieldWidget(
                                                  readOnly: true,
                                                  hintText: "",
                                                  controller: name,
                                                  onTypingFunction: (value) {},
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelText: "Name 🔒"),
                                              InputFieldWidget(
                                                  readOnly: false,
                                                  hintText: "",
                                                  controller: description,
                                                  onTypingFunction: (value) {
                                                    description = value;
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelText: "Description"),
                                              InputFieldWidget(
                                                  readOnly: false,
                                                  hintText: "",
                                                  controller: quantity
                                                      .toStringAsFixed(0),
                                                  onTypingFunction: (value) {
                                                    quantity =
                                                        double.parse(value);
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  labelText: "Quantity"),
                                              InputFieldWidget(
                                                  readOnly: false,
                                                  hintText: "",
                                                  controller: amount.toString(),
                                                  onTypingFunction: (value) {
                                                    amount =
                                                        double.parse(value);
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  labelText: "Price"),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      backgroundColor:
                                                          kFontGreyColor,
                                                    ),
                                                    child: Text(
                                                      'Cancel',
                                                      style: kNormalTextStyle
                                                          .copyWith(
                                                              color:
                                                                  kPureWhiteColor),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (tracking == true) {
                                                        if (quantity <=
                                                            instockQuantity) {
                                                          Provider.of<StyleProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .addToServiceBasket(BasketItem(
                                                                  name: name,
                                                                  quantity:
                                                                      quantity,
                                                                  amount:
                                                                      amount,
                                                                  details:
                                                                      description,
                                                                  tracking:
                                                                      tracking));
                                                          Provider.of<StyleProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .addSelectedStockItems(Stock(
                                                                  name: name,
                                                                  id: id,
                                                                  restock:
                                                                      quantity,
                                                                  price:
                                                                      amount /
                                                                          1.0));
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return CupertinoAlertDialog(
                                                                  title: const Text(
                                                                      'Quantity Too High'),
                                                                  content: Text(
                                                                    "The quantity available for ${name} is ${instockQuantity}! You have tried to sell ${quantity} units!",
                                                                    style: kNormalTextStyle
                                                                        .copyWith(
                                                                            color:
                                                                                kBlack),
                                                                  ),
                                                                  actions: [
                                                                    CupertinoDialogAction(
                                                                        isDestructiveAction:
                                                                            true,
                                                                        onPressed:
                                                                            () {
                                                                          // _btnController.reset();

                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            'Cancel')),
                                                                    CupertinoDialogAction(
                                                                        isDefaultAction:
                                                                            true,
                                                                        onPressed:
                                                                            () async {
                                                                          final prefs =
                                                                              await SharedPreferences.getInstance();
                                                                          Provider.of<BeauticianData>(context, listen: false)
                                                                              .setStoreId(prefs.getString(kStoreIdConstant));

                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              UpdateStockPage.id);
                                                                        },
                                                                        child: const Text(
                                                                            'Update Stock')),
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      } else {
                                                        Provider.of<StyleProvider>(
                                                                context,
                                                                listen: false)
                                                            .addToServiceBasket(
                                                                BasketItem(
                                                                    name: name,
                                                                    quantity:
                                                                        quantity,
                                                                    amount:
                                                                        amount,
                                                                    details:
                                                                        description,
                                                                    tracking:
                                                                        tracking));
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      }
                                                      print(
                                                          "THIS IS AT POS STAGE $selectedStocks");
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      backgroundColor:
                                                          kCustomColorPink,
                                                    ),
                                                    child: Text(
                                                      'Add Product',
                                                      style: kNormalTextStyle
                                                          .copyWith(
                                                              color:
                                                                  kPureWhiteColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child:
                                  productItemsCard(name: name, amount: amount),
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
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return Scaffold(
                                  appBar: AppBar(
                                    automaticallyImplyLeading: false,
                                    backgroundColor: kBlack,
                                  ),
                                  body: ProductUpload());
                            });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: kAppPinkColor,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(child: Icon(Icons.add),),
                      )
                    ),
                    Text(
                      "Create Product",
                      style: kNormalTextStyle.copyWith(
                          color: kBlueDarkColor, fontSize: 10),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class productItemsCard extends StatelessWidget {
  const productItemsCard({
    super.key,
    required this.name,
    required this.amount,
  });

  final String name;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kBackgroundGreyColor,
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(
            color: kBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          CommonFunctions().formatter.format(amount),
          style: TextStyle(
            color: kBlack,
          ),
        ),
      ),
    );
  }
}
