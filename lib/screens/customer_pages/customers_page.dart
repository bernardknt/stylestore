import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:cool_alert/cool_alert.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/controllers/responsive/responsive_page.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/customer_pages/add_customers_page.dart';
import 'package:stylestore/screens/customer_pages/customer_edit_page.dart';
import 'package:stylestore/screens/customer_pages/customer_transactions.dart';
import 'package:stylestore/screens/customer_pages/customer_transactions_web.dart';
import 'package:stylestore/screens/customer_pages/search_detailed_customer.dart';

import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import 'package:stylestore/widgets/customer_content.dart';
import 'package:stylestore/widgets/rounded_buttons.dart';
import '../../Utilities/InputFieldWidget.dart';
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
  var id = [];
  var phoneNumberList = [];
  var locationList = [];
  var customerNameList = [];
  var customerName = "";
  var customerId = "";
  var phoneNumber = "";
  var location = "";
  var description = "";
  var colour = [];
  var infoList = [];
  List<Map> items = [];
  var price = [];
  var photoImage = [];
  var formatter = NumberFormat('#,###,000');
  var storeId = '';
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};
  final RoundedLoadingButtonController _btnController =
  RoundedLoadingButtonController();
  List<bool> visible = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List contactList = [];
  late TextEditingController controller;

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

  CollectionReference customerProvided =
  FirebaseFirestore.instance.collection('customers');
  Future<void> addCustomer(nameOfCustomer, phoneNumberOfCustomer) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> optionsToUpload = {
      'Joined': '${DateFormat('EE, dd, MMM, hh:mm a').format(DateTime.now())}',
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
          .showSnackBar(SnackBar(content: Text('Error creating Customer')));
    });
  }

  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    storeId = prefs.getString(kStoreIdConstant)!;
    setState(() {});
  }

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
        floatingActionButtonLocation:
        FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: permissionsMap['customers'] == false
            ? Container()
            : FloatingActionButton(
            backgroundColor: kAppPinkColor,
            onPressed: () {
              // add Ingredient Here
              Provider.of<StyleProvider>(context, listen: false)
                  .resetCustomerUploadItem();
              // Navigator.pushNamed(context, AddCustomersPage.id);
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
                                                Icons.contacts_outlined,
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
                            // kLargeHeightSpacing,
                            // kLargeHeightSpacing,
                            // kLargeHeightSpacing,
                            // kLargeHeightSpacing,
                            // kLargeHeightSpacing,
                            // kLargeHeightSpacing,
                            // kLargeHeightSpacing,
                            // Text("Cancel", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                          ],
                        ),
                      ),
                    );
                  });
            },
            child: Icon(
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
          actions: [],
        ),
        body: permissionsMap['customers'] == false
            ? LockedWidget(page: "Customers")
            : Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.only(top: 8.0, left: 50, right: 50),
              child: GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();

                    Provider.of<BeauticianData>(context, listen: false)
                        .setStoreId(prefs.getString(kStoreIdConstant));

                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return Scaffold(
                              appBar: AppBar(
                                backgroundColor: kPureWhiteColor,
                                automaticallyImplyLeading: false,
                                elevation: 0,
                              ),
                              body: CustomerDetailedSearchPage());
                        });
                  },
                  child: Container(

                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border:
                        Border.all(width: 1, color: kFontGreyColor),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),

                        color: kBackgroundGreyColor,
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.search,
                            color: kFontGreyColor,
                          ),
                          kSmallWidthSpacing,
                          Text(
                            "Search Customers",
                            style: kNormalTextStyle,
                          )
                        ],
                      ))),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('customers')
                      .where('active', isEqualTo: true)
                      .where('storeId', isEqualTo: storeId)
                      .orderBy('name', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: kAppPinkColor,
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return Container(
                        color: Colors.white,
                      );
                    } else {
                      id = [];
                      phoneNumberList = [];
                      locationList = [];
                      customerNameList = [];
                      infoList = [];
                      items = [];
                      photoImage = [];
                      colour = [];
                      visible = [];

                      var customers = snapshot.data!.docs;
                      for (var customer in customers) {
                        id.add(customer.get('id'));
                        phoneNumberList.add(customer.get('phoneNumber'));
                        locationList.add(customer.get('location'));
                        customerNameList.add(customer.get('name'));
                        infoList.add(customer.get('info'));
                        photoImage.add(customer.get('image'));
                        items.add(customer.get('options'));
                        price.add(0);
                        colour.add(Colors.black45);
                      }

                      return customerNameList.isEmpty
                          ? CustomPopupWidget(
                        backgroundColour: kBlueDarkColor,
                        actionButton: 'Add Customer',
                        subTitle: 'Add Customers: Tap and sell',
                        image: 'customer.jpg',
                        title: 'Build Loyal Customers',
                        function: () {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return Scaffold(
                                    body: AddCustomersPage());
                              });
                        },
                        youtubeLink: videoMap['customers'],
                      )
                          : ListView.builder(
                          itemCount: id.length,
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
                                                  color: Color(0xFF292929)
                                                      .withOpacity(0.6),
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                        color:
                                                        kPureWhiteColor,
                                                        borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(
                                                                30),
                                                            topRight: Radius
                                                                .circular(
                                                                30))),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          top: 20.0,
                                                          bottom: 50,
                                                          left: 20),
                                                      child: Column(
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        children: [
                                                          buildButton(context, 'Edit ${customerNameList[index]}', Icons.edit, () async {
                                                                Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(customerNameList[index], phoneNumberList[index], infoList[index], items[index].toString().replaceAll('{', '').replaceAll('}', ''), photoImage[index], locationList[index], id[index]);
                                                                Navigator.pop(context);
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerEditPage()));}), SizedBox(height: 16.0),
                                                          buildButton(context, 'Buying History of ${customerNameList[index]}', Icons.send,
                                                                  () async {
                                                                Navigator.pop(context);

                                                                Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(customerNameList[index], phoneNumberList[index], infoList[index], items[index].toString().replaceAll('{', '').replaceAll('}', ''), photoImage[index], locationList[index], id[index]);
                                                                Provider.of<BeauticianData>(context, listen: false).setClientName(customerNameList[index], id[index]);
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(builder: (context) => SuperResponsiveLayout(mobileBody: CustomerTransactionsProducts(), desktopBody: CustomerTransactionsWeb())),
                                                                );
                                                              }),
                                                          items.length != 0
                                                              ? buildButton(
                                                              context,
                                                              '${customerNameList[index]} Extra Details',
                                                              Icons
                                                                  .person_add,
                                                                  () async {
                                                                Navigator.pop(
                                                                    context);
                                                                showDialog(
                                                                    context:
                                                                    context,
                                                                    builder:
                                                                        (BuildContext
                                                                    context) {
                                                                      return GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child:
                                                                        Material(
                                                                          color: Colors.transparent,
                                                                          child: Stack(
                                                                            children: [
                                                                              CupertinoAlertDialog(
                                                                                title: Column(
                                                                                  children: [
                                                                                    Text(customerNameList[index]),
                                                                                    Text(
                                                                                      "Key Details",
                                                                                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                content: Container(
                                                                                  width: 100,
                                                                                  height: 300,
                                                                                  // color: Colors.teal,
                                                                                  child: ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      itemCount: items[index].keys.toList().length,
                                                                                      itemBuilder: (context, i) {
                                                                                        return CustomerContentsWidget(orderIndex: i + 1, optionName: items[index].keys.toList()[i], optionValue: items[index].values.toList()[i]);
                                                                                      }),
                                                                                ),
                                                                                actions: [
                                                                                  CupertinoDialogAction(
                                                                                      isDestructiveAction: true,
                                                                                      onPressed: () {
                                                                                        // _btnController.reset();
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: const Text('Cancel'))
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                              })
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        }else{
                                          Provider.of<BeauticianData>(context).setCustomerDetails(customerNameList[index], phoneNumberList[index], infoList[index], items[index].toString().replaceAll('{', '').replaceAll('}', ''), photoImage[index], locationList[index], id[index]);
                                          Provider.of<BeauticianData>(context).setClientName(customerNameList[index], id[index]);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => SuperResponsiveLayout(mobileBody: CustomerTransactionsProducts(), desktopBody: CustomerTransactionsWeb())),
                                          );

                                        }

                                      },
                                      child:
                                      Container(
                                          padding: EdgeInsets.all(20),
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
                                                          capitalizeString(
                                                              customerNameList[
                                                              index]),
                                                          style: kNormalTextStyleMoney
                                                              .copyWith(
                                                              fontSize:
                                                              14),
                                                        ),
                                                        Text(
                                                          '${phoneNumberList[index]}',
                                                          style:
                                                          kNormalTextStyleDark,
                                                        ),
                                                        Text(
                                                          'Location: ${capitalizeString(locationList[index])}',
                                                          style:
                                                          kNormalTextStyleDark,
                                                        ),
                                                        Text(
                                                          'Note: ${capitalizeString(infoList[index])}',
                                                          style:
                                                          kNormalTextStyleDark,
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: phoneNumberList[index] !=
                                                        ""? Padding(padding: const EdgeInsets.only(right: 80.0, top: 10), child: RoundedButtons(
                                                      buttonColor:
                                                      kBlueDarkColor,
                                                      title:
                                                      "Call",
                                                      onPressedFunction:
                                                          () {
                                                        CommonFunctions()
                                                            .callPhoneNumber(phoneNumberList[index]);
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
                                                              photoImage[
                                                              index]),
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
                                                                      id[index],
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
                                                                'Name: ${customerNameList[index]}\nNumber: ${phoneNumberList[index]}\nLocation: ${locationList[index]}',
                                                                subject:
                                                                'Here are the customer details of ${customerNameList[index]}');
                                                          },
                                                          child: CircleAvatar(
                                                              backgroundColor: kCustomColor,
                                                              radius: 15,
                                                              child: Icon(
                                                                Icons
                                                                    .share_outlined,
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
                                      Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(customerNameList[index], phoneNumberList[index], infoList[index], items[index].toString().replaceAll('{', '').replaceAll('}', ''), photoImage[index], locationList[index], id[index]);
                                      Provider.of<BeauticianData>(context, listen: false).setClientName(customerNameList[index], id[index]);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SuperResponsiveLayout(mobileBody: CustomerTransactionsProducts(), desktopBody: CustomerTransactionsWeb())),
                                      );
                                    },
                                      child: Container(
                                          padding: EdgeInsets.all(20),
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
                                                          capitalizeString(
                                                              customerNameList[
                                                              index]),
                                                          style: kNormalTextStyleMoney
                                                              .copyWith(
                                                              fontSize:
                                                              14),
                                                        ),
                                                        Text(
                                                          '${phoneNumberList[index]}',
                                                          style:
                                                          kNormalTextStyleDark,
                                                        ),
                                                        Text(
                                                          'Location: ${capitalizeString(locationList[index])}',
                                                          style:
                                                          kNormalTextStyleDark,
                                                        ),
                                                        Text(
                                                          'Note: ${capitalizeString(infoList[index])}',
                                                          style:
                                                          kNormalTextStyleDark,
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: phoneNumberList[index] !=
                                                        ""? Padding(padding: const EdgeInsets.only(right: 80.0, top: 10), child: RoundedButtons(
                                                      buttonColor:
                                                      kBlueDarkColor,
                                                      title:
                                                      "Call",
                                                      onPressedFunction:
                                                          () {
                                                        CommonFunctions()
                                                            .callPhoneNumber(phoneNumberList[index]);
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
                                                              photoImage[
                                                              index]),
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
                                                                  // Provider.of<BlenditData>(context, listen: false).deleteItemFromBasket(blendedData.basketItems[index]);
                                                                  // FirebaseServerFunctions().removePostFavourites(docIdList[index],postId[index], userEmail);
                                                                  CommonFunctions().removeDocumentFromServer(
                                                                      id[index],
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
                                                                'Name: ${customerNameList[index]}\nNumber: ${phoneNumberList[index]}\nLocation: ${locationList[index]}',
                                                                subject:
                                                                'Here are the customer details of ${customerNameList[index]}');
                                                          },
                                                          child: CircleAvatar(
                                                              backgroundColor: kCustomColor,
                                                              radius: 15,
                                                              child: Icon(
                                                                Icons
                                                                    .share_outlined,
                                                                size: 15,
                                                              )))),
                                                ],
                                              ),
                                            ],
                                          )),
                                  );
                                }
                              }

                            );
                          });
                    }
                  }),
            ),
          ],
        ));
  }
}
