
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/screens/customer_pages/customer_data.dart';
import 'package:stylestore/screens/employee_pages/edit_employee_profile_page.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';
import '../../widgets/rounded_icon_widget.dart';
import '../employee_pages/employee_details.dart';
import '../team_pages/employee_permissions_page.dart';


class BulkSmsPage extends StatefulWidget {
  static String id = "bulkSms_page";
  const BulkSmsPage({super.key});

  @override
  State<BulkSmsPage> createState() => _BulkSmsPageState();
}

class _BulkSmsPageState extends State<BulkSmsPage> {
  List<AllCustomerData> newCustomers = [];
  String businessId = '';
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};
  TextEditingController controller  = TextEditingController()..text = '';

  var message  = "";

  Future<List<AllCustomerData>> retrieveCustomerData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('storeId', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
          .orderBy('name', descending: false)
          .get();

      final customerDataList = snapshot.docs
          .map((doc) => AllCustomerData.fromFirestore(doc))
          .toList();

      return customerDataList;
    } catch (error) {
      print('Error retrieving employee data: $error');
      return []; // Return an empty list if an error occurs
    }
  }

  TextEditingController searchController = TextEditingController();
  List<AllCustomerData> filteredCustomers = [];


  @override
  void initState() {
    defaultInitialization();

    super.initState();
  }

  void filterEmployees(String query) {
    setState(() {
      filteredCustomers = newCustomers
          .where((employee) =>
      employee.fullNames.toLowerCase().contains(query.toLowerCase()) ||
          employee.fullNames.toLowerCase().contains(query.toLowerCase()) ||
          employee.phone.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


  void defaultInitialization() async {

    controller.text = Provider.of<BeauticianData>(context, listen: false).textMessage;
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    newCustomers = await retrieveCustomerData();
    print(newCustomers);
    filteredCustomers.addAll(newCustomers);
    setState(() {});
  }

// Helper method to build information card
  Widget buildInfoCard(
      {required String title,
        required String value,
        Color cardColor = kBackgroundGreyColor,
        IconData cardIcon = Icons.accessibility}) {
    return Tooltip(
      message: title,
      child: Card(
        color: cardColor.withOpacity(0.2),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              kSmallHeightSpacing,
              Icon(
                cardIcon,
                color: cardColor.withOpacity(0.6),
              ),
              kSmallHeightSpacing,
              Text(
                value,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    var beauticianDataListen = Provider.of<BeauticianData>(context);
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAppPinkColor,
        onPressed: () {

        },
        label: Text("Send", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),


      ),

      body:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // Row of four cards
            Text("Type your message here",style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold),),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
              TextField(
                controller:controller,
                maxLength: 160,
                onChanged: (enteredQuestion){
                  print(enteredQuestion);
                  message = enteredQuestion;
                  beauticianDataListen.setTextMessage(enteredQuestion);
                },
                maxLines: null,
                decoration: InputDecoration(
                  border:
                  //InputBorder.none,
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  labelText: 'Message',
                  labelStyle: kNormalTextStyleExtraSmall,
                  hintText: '',
                  hintStyle: kNormalTextStyle,

                ),

              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Send the message to:",style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold),),
                    kSmallWidthSpacing,
                    Container(
                      decoration: BoxDecoration(
                        color: kPlainBackground,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Icon(Icons.people_alt_outlined),
                            kSmallWidthSpacing,
                            Text("${Provider.of<StyleProvider>(context).bulkNumbers.length}")
                          ]

                        ),
                      ),
                    )
                  ],
                ),

                Container(
                  decoration: BoxDecoration(
                    color: kGreenThemeColor,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Add Manually", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                  ),
                )
              ],
            ),
            kSmallHeightSpacing,
            SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Provider.of<StyleProvider>(context).bulkNumbers.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: (){
                      Provider.of<StyleProvider>(context, listen: false).addBulkSmsList(Provider.of<StyleProvider>(context, listen: false).bulkNumbers[i]);
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.only(
                          right: 3.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSalesButtonColor,
                          borderRadius:
                          BorderRadius.circular(
                              10),
                        ),
                        child: Padding(
                          padding:
                          const EdgeInsets.all(
                              8.0),
                          child: Text(
                            Provider.of<StyleProvider>(context, listen: false).bulkNumbers[i],
                            style:
                            kNormalTextStyleDark
                                .copyWith(
                              color:
                              kBlack,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search Customer',
                      hintFadeDuration: Duration(milliseconds: 100),
                    ),
                    onChanged: filterEmployees,
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kCustomersButtonColor,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Select All", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 12),),
                      ),
                    )
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      leading: RoundImageRing(
                        networkImageToUse: filteredCustomers[index].photo,
                        outsideRingColor: kBackgroundGreyColor,
                        radius: 48,
                      ),
                      title: Text(
                        "${filteredCustomers[index].fullNames}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Provider.of<StyleProvider>(context, listen: true).bulkNumbers.contains(filteredCustomers[index].phone)?Icon(Icons.check_circle_outline, color: kGreenThemeColor,size: 14,):Icon(Icons.add, size: 14,),
                      subtitle: Text('Phone: ${filteredCustomers[index].phone}'),
                      onTap: () {
                        // Handle employee item tap
                        Provider.of<StyleProvider>(context, listen: false).addBulkSmsList(filteredCustomers[index].phone);
                      },
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
