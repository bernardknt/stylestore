import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';

class CompanyDocumentationWidget extends StatelessWidget {
  CompanyDocumentationWidget({required this.heading, required this.subheading});
  final String heading;
  final String subheading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          final url = 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SfPdfViewer.network(
                url,

              ),
            ),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: kIconSize,
              backgroundColor: kBlueDarkColor,
              child: Icon(
                Icons.picture_as_pdf,
                color: kPureWhiteColor,
              ),
            ),
            SizedBox(width: 16),
            Container(
              // width: 180,
              child: Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      overflow: TextOverflow.ellipsis,
                      style: kNormalTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kBlack,
                          fontSize: 12),
                    ),
                    Text(
                      subheading,
                      overflow: TextOverflow.ellipsis,
                      style: kNormalTextStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
