



import 'package:flutter/material.dart';
import 'package:stylestore/controllers/responsive/responsive_dimensions.dart';





class SuperResponsiveLayout extends StatefulWidget {
  static String id = "responsive_layout";
  final Widget mobileBody;
  final Widget desktopBody;
  const SuperResponsiveLayout({super.key, required this.mobileBody, required this.desktopBody});

  @override
  State<SuperResponsiveLayout> createState() => _SuperResponsiveLayoutState();
}

class _SuperResponsiveLayoutState extends State<SuperResponsiveLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints){
      if (constraints.maxWidth< mobileWidth){
        return widget.mobileBody;
      }else {
        return widget.desktopBody;
      }
    });
  }
}
