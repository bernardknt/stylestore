


import 'package:flutter/material.dart';

Widget BuildImage (String urlImage, int index) => Container(
  // margin: EdgeInsets.symmetric(horizontal: 10),
  //  decoration: BoxDecoration(
  //    // color: Colors.grey,
  //      borderRadius: BorderRadius.circular(20),
  //      // image: DecorationImage(
  //      //   image:
  //      //   FadeInImage.assetNetwork(placeholder: 'images/shimmer.gif', image: urlImage,),
  //      //   NetworkImage(urlImage),
  //      //   fit: BoxFit.cover,
  //      //
  //      // ),
  //
  //  ),
  child: Image.asset("images/welcome.jpg",
    fit:  BoxFit.cover,
    width: double.maxFinite,


  )
  // FadeInImage.assetNetwork(
  //   placeholder: 'images/shimmer.gif',
  //   image: urlImage, width: double.maxFinite,
  //   fit: BoxFit.cover,
  // ),
);

