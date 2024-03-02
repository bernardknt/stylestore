
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
// import 'package:stylestore/model/common_functions.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
//
import '../Utilities/constants/user_constants.dart';

class DocumentsPage extends StatefulWidget {
  static String id = 'documents_page';

  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  // File? _selectedFile;
  //
  // Future<void> _selectFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf'],
  //   );
  //
  //   if (result != null) {
  //     setState(() {
  //       _selectedFile = File(result.files.single.path!);
  //     });
  //   }
  // }

  // Future<void> _uploadFile() async {
  //   if (_selectedFile == null) return;
  //
  //   try {
  //     Reference storageReference = FirebaseStorage.instance
  //         .ref()
  //         .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
  //
  //     UploadTask uploadTask = storageReference.putFile(_selectedFile!);
  //
  //     await uploadTask.whenComplete(() async {
  //       String downloadUrl = await storageReference.getDownloadURL();
  //
  //       await FirebaseFirestore.instance.collection('documents').add({
  //         'name': _selectedFile!.path.split('/').last,
  //         'url': downloadUrl,
  //       });
  //
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('PDF Uploaded Successfully'),
  //       ));
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Failed to upload PDF'),
  //     ));
  //   }
  // }
  var createdBy = [];
  var idList = [];
  var createdDate = [];
  var titleList = [];
  var urlList = [];
  String storeId = '';
  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant) ?? "";


    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlainBackground,
      appBar: AppBar(
        title: Text('Documentations',
            style: kNormalTextStyle.copyWith(fontSize: 20)),
      ),
      body:

      StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('documents')
          // .where('storeId', isEqualTo: storeId)
          // .orderBy('createdDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else {
              createdBy = [];
              idList = [];
              createdDate = [];
              titleList = [];
              urlList = [];


              var orders = snapshot.data?.docs;
              print(orders);
              for (var order in orders!) {

                createdBy.add(order.get('createdBy'));
                idList.add(order.get('id'));
                createdDate.add(order.get('createDate').toDate());
                titleList.add(order.get('title'));
                urlList.add(order.get('url'));


              }
              // return Text('Let us understand this ${deliveryTime[3]} ', style: TextStyle(color: Colors.white, fontSize: 25),);
              return idList.length == 0
                  ? Container(
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.designtools5,
                          color: kAppPinkColor,
                        ),
                        Text(
                          "Your Tasks will appear here",
                          style: kNormalTextStyle,
                        ),
                      ],
                    )),
              )
              // Center(child: Text("Nothing"),)
                  : StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  itemCount: idList.length,
                  crossAxisSpacing: 10,
                  // physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Stack(children: [
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => SfPdfViewer.network(
                          //       urlList[index],
                          //
                          //     ),
                          //   ),
                          // );
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              top: 10, right: 0, left: 0, bottom: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPureWhiteColor,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                //height: 170,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                    // DividingLine(),
                                    Text(titleList[index],
                                      style:
                                      kNormalTextStyleDark.copyWith(
                                        color:kBlack, fontWeight: FontWeight.bold, fontSize: 16
                                      ),
                                    ),
                                    Image.asset('images/writing.png',),


                                    Text('${DateFormat('d-MM-yyyy').format(DateTime.now())}',
                                        style:
                                        kNormalTextStyleDark.copyWith(
                                            color: kFontGreyColor,
                                        )),

                                    Text(
                                      'Uploaded By:${createdBy[index]} ',
                                      style: kNormalTextStyleDark
                                          .copyWith(
                                          color: kFontGreyColor, fontSize: 12),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ]);
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1));
            }
          }),
      floatingActionButton: FloatingActionButton(
        foregroundColor: kPureWhiteColor,
        backgroundColor: kAppPinkColor,
        onPressed: () {

        },
        child: Icon(Icons.add),
      ),
    );
  }
}
