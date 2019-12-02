import 'package:coursei/appColors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final child;
  final ignorePadding;
  CustomAppBar({@required this.child, this.ignorePadding});
  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = EdgeInsets.symmetric(horizontal:12,vertical: 6);
    if (ignorePadding != null) padding = EdgeInsets.zero;

    return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.2),
              offset: Offset(0,2),
              blurRadius: 2
            )
          ]
        ),
        child: child,
      );
  }
}