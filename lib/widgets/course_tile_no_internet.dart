import 'package:flutter/material.dart';
import 'package:coursei/appColors.dart' as prefix0;
class CourseTileNoInternet extends StatelessWidget {
  final Function function;
  CourseTileNoInternet(this.function);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text("Sem conexão com a internet",
          style: TextStyle(
            color: prefix0.secondaryText,
            fontWeight: FontWeight.w600,
            fontSize: 14
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              width: MediaQuery.of(context).size.width * .5,
              height: 45,
              duration: Duration(milliseconds: 300),
              child: Material(
                shadowColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)
                  ),
                elevation: 6.0,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: prefix0.secondaryColor
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    elevation: 6.0,
                    color: Colors.transparent,
                    shadowColor: Colors.grey[50],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      splashColor: prefix0.secondarySplashColor,
                      onTap:function,
                      child: Center(
                        child: Text(
                          "Tentar novamente",
                          style: TextStyle(
                            color: prefix0.secondaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}