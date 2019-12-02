import 'package:coursei/appColors.dart' as prefix0;
import 'package:flutter/material.dart';

class AnyItemsFound extends StatelessWidget {
  final String description;
  AnyItemsFound(this.description);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * .8,
          maxHeight: 320
        ),
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: prefix0.greyBackground
        ),
        child: Column(
          children: <Widget>[
            Image.asset("assets/icons/ic_not_found.png",height: 200),
            SizedBox(height:12),
            Text("Nada por aqui...",
              style: TextStyle(
                color: prefix0.secondaryText,
                fontWeight: FontWeight.w700,
                fontSize: 18
              ),
            ),
            SizedBox(height:12),
            Text(description,
              style: TextStyle(
                color: prefix0.secondaryText,
                fontWeight: FontWeight.w600,
                fontSize: 15
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
    );
  }
}