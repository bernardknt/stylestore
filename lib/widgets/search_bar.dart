import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stylestore/screens/customer_pages/search_customer.dart';

import '../Utilities/constants/color_constants.dart';


class SearchBar extends StatelessWidget {
  const SearchBar({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return
      TextField(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.pushNamed(context, CustomerSearchPage.id);
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          focusColor: kBlueDarkColor,

          fillColor: kBackgroundGreyColor,
          filled: true,

          hoverColor: kBrownDarkColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          prefixIcon: Icon(LineIcons.search),
          // hintText: "...Search"
      ),
    );
  }
}