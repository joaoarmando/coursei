import 'package:coursei/appColors.dart';
import 'package:flutter/material.dart';
class AppBarButton extends StatelessWidget {
  final Color iconColor;
  final IconData icon;
  final Color backgroundColor;
  final Function function;
  final String imagePath;
  final double iconSize;
  AppBarButton({this.iconColor,  this.icon, this.imagePath, this.backgroundColor, @required this.function, this.iconSize});
  @override
  Widget build(BuildContext context) {
    var size = iconSize;
    if (iconSize == null) size = 35;
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: backgroundColor != null ? backgroundColor : Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: function,
          borderRadius: BorderRadius.circular(10),
          splashColor: primarySplashColor,
          child: icon != null ? Icon(icon, color: iconColor != null ? iconColor : secondaryText, size: size,) 
            : Padding(
              padding: EdgeInsets.all(8),
              child: Image.asset("$imagePath"),
            )
        ),
      ),
    );
  }
}