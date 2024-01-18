

import 'package:flutter/material.dart';


import '../utilities/constants/color_constants.dart';

class TicketDots extends StatelessWidget {
  TicketDots({required this.mainColor, this.circleColor =  kAppPinkColor, this.backgroundColor = kPureWhiteColor});
  final Color mainColor;
  final Color circleColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: 40,
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color:  circleColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)
                  )
              ),
            ),
          ),
          Expanded(child:
          SizedBox(
            height: 24,
            child: LayoutBuilder(

              builder: (BuildContext context, BoxConstraints constraints) {
                return Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children:
                    List.generate((constraints.constrainWidth()/6).floor(), (index) => SizedBox(
                      width: 3, height: 1,
                      child:
                      DecoratedBox(decoration: BoxDecoration(
                          color:mainColor
                      ),),
                    ))
                );
              },

            ),
          )
          ),
          SizedBox(
            height: 20,
            width: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: circleColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)
                  )
              ),
            ),
          )
        ],
      ),
    );
  }
}
