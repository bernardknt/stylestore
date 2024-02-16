// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:stylestore/Utilities/constants/font_constants.dart';
//
// class DocumentsPage extends StatelessWidget {
//   static String id = 'all_documents_page';
//
//   const DocumentsPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Documentations', style: kNormalTextStyle.copyWith(fontSize: 20)),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('documents').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(
//               child: Text('No documents found\nPlease add some documents', textAlign: TextAlign.center, style:kNormalTextStyle,),
//             );
//           }
//           // If data is loading, show a progress indicator
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           final documents = snapshot.data!.docs;
//           return GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemCount: documents.length,
//             itemBuilder: (context, index) {
//               final document = documents[index];
//               final documentData = document.data() as Map<String, dynamic>;
//               final documentTitle = documentData['title'] as String;
//               final documentPreviewUrl = documentData['previewUrl'] as String;
//               return GestureDetector(
//                 onTap: () {
//                   // Handle document tile tap
//                 },
//                 child: GridTile(
//                   child: Image.network(documentPreviewUrl, fit: BoxFit.cover),
//                   footer: GridTileBar(
//                     backgroundColor: Colors.black45,
//                     title: Text(
//                       documentTitle,
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Handle add button tap
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
