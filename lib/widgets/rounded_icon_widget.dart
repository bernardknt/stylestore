import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utilities/constants/color_constants.dart';



class RoundImageRing extends StatelessWidget {
  const RoundImageRing({required this.networkImageToUse, required
  this.outsideRingColor, this.textAlignment = TextAlign.center,
    this.radius = 100, this.fontSize = 20, this.fontWeight = FontWeight.bold
  });

  final String networkImageToUse;

  final Color outsideRingColor;
  final TextAlign textAlignment;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;


  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    return Column(
      children: [
        Container(

          width: radius ,
          height: radius,
          decoration: BoxDecoration(
              shape: BoxShape.circle ,
              gradient:  LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kPlainBackground, kPlainBackground] ),
              border: Border.all(
                  color: outsideRingColor,
                  width: 2
              )
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              width: 45,
              height:  45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image:
                //     CachedNetworkImage(imageUrl: '',),
                CachedNetworkImageProvider(networkImageToUse),
                // NetworkImage(networkImageToUse),
                    fit: BoxFit.cover
                ),

              ),
              // child: CachedNetworkImage(imageUrl: networkImageToUse,height: 50,),


            ),
          ),
        ),
        // Text(labelText, textAlign: textAlignment??TextAlign.center, style: TextStyle(fontWeight: fontWeight??FontWeight.bold, color: textColor , fontSize: fontSize??14),),


      ],

    );
  }
}