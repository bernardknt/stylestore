import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/controllers/responsive/responsive_page.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/customer_pages/add_customers_page.dart';
import 'package:stylestore/screens/customer_pages/customer_data.dart';
import 'package:stylestore/screens/customer_pages/customer_edit_page.dart';
import 'package:stylestore/screens/customer_pages/customer_transactions.dart';
import 'package:stylestore/screens/customer_pages/customer_transactions_web.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import 'package:stylestore/widgets/customer_content.dart';
import 'package:stylestore/widgets/rounded_buttons.dart';
import '../../controllers/responsive/responsive_dimensions.dart';
import '../../utilities/constants/icon_constants.dart';
import '../../utilities/constants/user_constants.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';

class CustomerPage extends StatefulWidget {
  static String id = 'customers_page';



  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  var customerName = "";
  var customerId = "";
  var phoneNumber = "";
  var location = "";
  var description = "";
  List<Map> items = [];
  var formatter = NumberFormat('#,###,000');
  var storeId = '';
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};
  List<bool> visible = [];
  List contactList = [];
  // late TextEditingController controller;

  String capitalizeString(String input) {
    if (input.isEmpty) {
      return '';
    }

    return input[0].toUpperCase() + input.substring(1);
  }

  void getPermission() async {
    if (await Permission.contacts.isGranted) {
      // Fetch Contacts
    } else {
      // Permission request
      await Permission.contacts.request();
    }
  }

  CollectionReference customerProvided = FirebaseFirestore.instance.collection('customers');
  Future<void> addCustomer(nameOfCustomer, phoneNumberOfCustomer) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> optionsToUpload = {
      'Joined': DateFormat('EE, dd, MMM, hh:mm a').format(DateTime.now()),
    };

    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator(
                color: kAppPinkColor,
              ));
        });
    // Call the user's CollectionReference to add a new user
    return customerProvided.doc(customerId).set({
      'id': customerId,
      'image':
      "https://mcusercontent.com/f78a91485e657cda2c219f659/images/db929836-bf22-1b6d-9c82-e63932ac1fd2.png",
      'active': true,
      'phoneNumber': phoneNumberOfCustomer,
      'location': "Kampala",
      'category': 'main',
      'hasOptions': true,
      'info': "",
      'name': nameOfCustomer,
      'updateBy': "Bernard Kangave",
      'options': optionsToUpload,
      'storeId': prefs.getString(kStoreIdConstant),
    }).then((value) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${nameOfCustomer ?? ""} Created')));
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error creating Customer')));
    });
  }

  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    storeId = prefs.getString(kStoreIdConstant)!;
    newCustomers = await retrieveCustomerData();
    filteredCustomer.addAll(newCustomers);
    setState(() {});
  }

  Future<List<AllCustomerData>> retrieveCustomerData() async {

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('active', isEqualTo: true)
          .where('storeId', isEqualTo: storeId)
          .orderBy('name', descending: false)
          .get();

      final customerDataList = snapshot.docs
          .map((doc) => AllCustomerData.fromFirestore(doc))
          .toList();
      return customerDataList;
    } catch (error) {

      return []; // Return an empty list if an error occurs
    }
  }

  void filterCustomers(String query) {
    setState(() {
      filteredCustomer = newCustomers
          .where((supplier) =>
      supplier.fullNames.toLowerCase().contains(query.toLowerCase()) ||
          supplier.fullNames.toLowerCase().contains(query.toLowerCase())
          || supplier.phone.toLowerCase().contains(query.toLowerCase())
          || supplier.location.toLowerCase().contains(query.toLowerCase())
      )
          .toList();
    });
  }

  TextEditingController searchController = TextEditingController();
  List<AllCustomerData> filteredCustomer = [];
  List<AllCustomerData> newCustomers = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    var storeData = Provider.of<BeauticianData>(context, listen: false);
    return Scaffold(
        backgroundColor: Colors.white,
        // floatingActionButtonLocation:
        // FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: permissionsMap['customers'] == false
            ? Container() : FloatingActionButton(backgroundColor: kAppPinkColor, onPressed: () {
              // add Ingredient Here
              Provider.of<StyleProvider>(context, listen: false)
                  .resetCustomerUploadItem();

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ADD A NEW CUSTOMER",
                              textAlign: TextAlign.center,
                              style: kNormalTextStyle.copyWith(
                                  fontSize: 14,
                                  color: kPureWhiteColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            kLargeHeightSpacing,
                            kLargeHeightSpacing,
                            kLargeHeightSpacing,
                            kLargeHeightSpacing,
                            kLargeHeightSpacing,
                            Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // Navigator.pop(context);
                                            CommonFunctions.syncContacts(
                                                context, 2);
                                          },
                                          child: CircleAvatar(
                                              radius: 30,
                                              backgroundColor:
                                              kAppPinkColor.withOpacity(1),
                                              child: const Icon(
                                                Icons.cloud,
                                                color: kPureWhiteColor,
                                                size: 30,
                                              )),
                                        ),
                                        Text(
                                          "Sync from Contacts",
                                          style: kNormalTextStyle.copyWith(
                                              color: kPureWhiteColor,
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                    kMediumWidthSpacing,
                                    kMediumWidthSpacing,
                                    kMediumWidthSpacing,
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                                context, AddCustomersPage.id);
                                          },
                                          child: CircleAvatar(
                                              backgroundColor:
                                              kCustomColor.withOpacity(1),
                                              radius: 30,
                                              child: const Icon(
                                                Iconsax.mobile,
                                                color: kBlack,
                                                size: 30,
                                              )),
                                        ),
                                        Text(
                                          "Enter Manually",
                                          style: kNormalTextStyle.copyWith(
                                              color: kPureWhiteColor,
                                              fontSize: 12),
                                        )
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
            child: const Icon(
              CupertinoIcons.add,
              color: kPureWhiteColor,
            )),
        appBar: AppBar(
          backgroundColor: kPureWhiteColor,
          // automaticallyImplyLeading: false,
          title: Text(
            'Customers',
            style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 16),
          ),
          elevation: 0,
          centerTitle: true,

        ),
        body: permissionsMap['customers'] == false
            ? const LockedWidget(page: "Customers")
            : Column(

          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText:  "Search Customer by Name / Location",
                  hintFadeDuration: Duration(milliseconds: 100),
                ),
                onChanged: filterCustomers,
              ),
            ),
            Expanded(
                child:

                filteredCustomer.isEmpty ?

                    Container(child: Text("Let us add some customers"),)

                // CustomPopupWidget(
                //   backgroundColour: kBlueDarkColor,
                //   actionButton: 'Add Customer',
                //   subTitle: 'Add Customers: Tap and sell',
                //   image: 'customer.jpg',
                //   title: 'Build Loyal Customers',
                //   function: () {
                //     showModalBottomSheet(
                //         isScrollControlled: true,
                //         context: context,
                //         builder: (context) {
                //           return Scaffold(body: AddCustomersPage());});
                //   },
                //   youtubeLink: videoMap['customers'],
                // )
                    :

                ListView.builder(
                    itemCount: filteredCustomer.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints){
                            if (constraints.maxWidth<screenDisplayWidth){
                              return
                                GestureDetector(

                                    onTap: ()
                                    {
                                      storeData.changeCustomerDetailsVisibility(index);
                                      if (constraints.maxWidth <
                                          screenDisplayWidth){
                                        showModalBottomSheet(
                                            context: context,
                                            builder:
                                                (BuildContext context) {
                                              return Container(
                                                color: Colors.transparent,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      color:
                                                      kPureWhiteColor,
                                                      borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(30), topRight: Radius
                                                          .circular(
                                                          30))),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(top: 20.0,bottom: 50,left: 20),
                                                    child: Column(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      children: [
                                                        buildButton(context, 'Edit ${filteredCustomer[index].fullNames}', Icons.edit, () async {
                                                          Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(filteredCustomer[index].fullNames, filteredCustomer[index].phone, filteredCustomer[index].info, '{}', filteredCustomer[index].photo[index], filteredCustomer[index].location, filteredCustomer[index].documentId);
                                                          Navigator.pop(context);
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerEditPage()));}), const SizedBox(height: 16.0),
                                                        buildButton(context, 'Buying History of ${filteredCustomer[index].fullNames}', Icons.send,
                                                                () async {
                                                              Navigator.pop(context);

                                                              Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(filteredCustomer[index].fullNames, filteredCustomer[index].phone, filteredCustomer[index].info,'{}', filteredCustomer[index].photo, filteredCustomer[index].location, filteredCustomer[index].documentId);
                                                              Provider.of<BeauticianData>(context, listen: false).setClientName(filteredCustomer[index].fullNames, filteredCustomer[index].documentId);
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(builder: (context) => SuperResponsiveLayout(mobileBody: CustomerTransactionsProducts(), desktopBody: CustomerTransactionsWeb())),
                                                              );
                                                            }),

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      }else{
                                        Provider.of<BeauticianData>(context).setCustomerDetails(filteredCustomer[index].fullNames, filteredCustomer[index].phone, filteredCustomer[index].info, '{}', filteredCustomer[index].photo, filteredCustomer[index].location, filteredCustomer[index].documentId);
                                        Provider.of<BeauticianData>(context).setClientName(filteredCustomer[index].fullNames, filteredCustomer[index].documentId);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => SuperResponsiveLayout(mobileBody: CustomerTransactionsProducts(), desktopBody: CustomerTransactionsWeb())),
                                        );

                                      }

                                    },
                                    child: Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            TicketDots(
                                              mainColor: kFaintGrey,
                                              circleColor:
                                              kPureWhiteColor,
                                            ),
                                            Stack(
                                              children: [
                                                ListTile(
                                                  //title: Text(itemName[index]),
                                                  leading: Text(
                                                      '${index + 1}'),
                                                  title: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        capitalizeString(filteredCustomer[index].fullNames),
                                                        style: kNormalTextStyleMoney
                                                            .copyWith(
                                                            fontSize:
                                                            14),
                                                      ),
                                                      Text(
                                                        filteredCustomer[index].phone,
                                                        style:
                                                        kNormalTextStyleDark,
                                                      ),
                                                      Text(
                                                        'Location: ${capitalizeString(filteredCustomer[index].location)}',
                                                        style:
                                                        kNormalTextStyleDark,
                                                      ),
                                                      Text(
                                                        'Note: ${capitalizeString(filteredCustomer[index].info)}',
                                                        style:
                                                        kNormalTextStyleDark,
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: filteredCustomer[index].phone !=
                                                      ""? Padding(padding: const EdgeInsets.only(right: 80.0, top: 10), child: RoundedButtons(
                                                    buttonColor:
                                                    kBlueDarkColor,
                                                    title:
                                                    "Call",
                                                    onPressedFunction:
                                                        () {
                                                      CommonFunctions()
                                                          .callPhoneNumber(filteredCustomer[index].phone);
                                                    },
                                                    buttonHeight: 30,

                                                  ),
                                                  )
                                                      : Container(),
                                                  // Text("${items[index].keys.toList()}", style: kNormalTextStyleMoney.copyWith(color: kFaintGrey)),
                                                  trailing: Container(
                                                    height: 70,
                                                    width: 70,
                                                    margin:
                                                    const EdgeInsets
                                                        .only(
                                                        top: 10,
                                                        right: 0,
                                                        left: 0,
                                                        bottom: 3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
                                                      image:
                                                      DecorationImage(
                                                        image: CachedNetworkImageProvider(
                                                            filteredCustomer[index].photo
                                                        ),
                                                      )),
                                                  ),
                                                ),
                                                Positioned(
                                                    right: 10,
                                                    top: 5,
                                                    child:
                                                    GestureDetector(
                                                        onTap: () {
                                                          CoolAlert.show(
                                                              lottieAsset: 'images/question.json',
                                                              context: context,
                                                              type: CoolAlertType.success,
                                                              text: "Are you sure you want to remove this from your customers list",
                                                              title: "Remove Item?",
                                                              confirmBtnText: 'Yes',
                                                              confirmBtnColor: Colors.red,
                                                              cancelBtnText: 'Cancel',
                                                              showCancelBtn: true,
                                                              backgroundColor: kAppPinkColor,
                                                              onConfirmBtnTap: () {
                                                                CommonFunctions().removeDocumentFromServer(
                                                                    filteredCustomer[index].documentId,
                                                                    'customers');

                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                        },
                                                        child:
                                                        kIconCancel)),
                                                Positioned(
                                                    left: 10,
                                                    bottom: 8,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          Share.share(
                                                              'Name: ${filteredCustomer[index].fullNames}\nNumber: ${filteredCustomer[index].phone}\nLocation: ${filteredCustomer[index].location}',
                                                              subject:
                                                              'Here are the customer details of ${filteredCustomer[index].fullNames}');
                                                        },
                                                        child: const CircleAvatar(
                                                            backgroundColor: kCustomColor,
                                                            radius: 15,
                                                            child: Icon(
                                                              Icons.share_outlined,
                                                              size: 15,
                                                            )))),
                                              ],
                                            ),
                                          ],
                                        ))
                                );
                            }else {
                              return
                                GestureDetector(
                                  onTap: (){
                                    Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(filteredCustomer[index].fullNames, filteredCustomer[index].phone, filteredCustomer[index].info, '{}', filteredCustomer[index].photo,filteredCustomer[index].location, filteredCustomer[index].documentId);
                                    Provider.of<BeauticianData>(context, listen: false).setClientName(filteredCustomer[index].fullNames, filteredCustomer[index].documentId);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SuperResponsiveLayout(mobileBody: CustomerTransactionsProducts(), desktopBody: CustomerTransactionsWeb())),
                                    );
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          TicketDots(
                                            mainColor: kFaintGrey,
                                            circleColor:
                                            kPureWhiteColor,
                                          ),
                                          Stack(
                                            children: [
                                              ListTile(
                                                //title: Text(itemName[index]),
                                                leading: Text(
                                                    '${index + 1}'),
                                                title: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      capitalizeString(filteredCustomer[index].fullNames),
                                                      style: kNormalTextStyleMoney
                                                          .copyWith(
                                                          fontSize:
                                                          14),
                                                    ),
                                                    Text(
                                                      filteredCustomer[index].phone,
                                                      style:
                                                      kNormalTextStyleDark,
                                                    ),
                                                    Text(
                                                      'Location: ${capitalizeString(filteredCustomer[index].location)}',
                                                      style:
                                                      kNormalTextStyleDark,
                                                    ),
                                                    Text(
                                                      'Note: ${capitalizeString(filteredCustomer[index].info)}',
                                                      style:
                                                      kNormalTextStyleDark,
                                                    ),
                                                  ],
                                                ),
                                                subtitle: filteredCustomer[index].phone !=
                                                    ""? Padding(padding: const EdgeInsets.only(right: 80.0, top: 10), child: RoundedButtons(
                                                  buttonColor:
                                                  kBlueDarkColor,
                                                  title:
                                                  "Call",
                                                  onPressedFunction:
                                                      () {
                                                    CommonFunctions()
                                                        .callPhoneNumber(filteredCustomer[index].phone);
                                                  },
                                                  buttonHeight: 30,

                                                ),
                                                )
                                                    : Container(),
                                                // Text("${items[index].keys.toList()}", style: kNormalTextStyleMoney.copyWith(color: kFaintGrey)),
                                                trailing: Container(
                                                  height: 70,
                                                  width: 70,
                                                  margin:
                                                  const EdgeInsets
                                                      .only(
                                                      top: 10,
                                                      right: 0,
                                                      left: 0,
                                                      bottom: 3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
                                                    image:
                                                    DecorationImage(
                                                      image: CachedNetworkImageProvider(filteredCustomer[index].photo),
                                                    )),
                                                ),
                                              ),
                                              Positioned(
                                                left: 10,
                                                bottom: 8,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      Share.share(
                                                          'Name: ${filteredCustomer[index].fullNames}\nNumber: ${filteredCustomer[index].phone}\nLocation: ${filteredCustomer[index].location}',
                                                          subject:
                                                          'Here are the customer details of ${filteredCustomer[index].fullNames}');
                                                    },
                                                    child: const CircleAvatar(
                                                        backgroundColor: kCustomColor,
                                                        radius: 15,
                                                        child: Icon(
                                                          Icons.share_outlined,size: 15,))),)],
                                          ),
                                        ],
                                      )),
                                );
                            }
                          }
                      );
                    }
                )
            )
          ],
        ));
  }
}
