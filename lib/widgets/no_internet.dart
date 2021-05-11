import 'package:flutter/material.dart';
import 'package:coursei/appColors.dart';
class NoInternet extends StatelessWidget {
  final Function function;
  NoInternet(this.function);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("Sem conexão com a internet",
          style: TextStyle(
            color: secondaryText,
            fontWeight: FontWeight.w600,
            fontSize: 21
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              width: MediaQuery.of(context).size.width * .5,
              height: 50,
              duration: Duration(milliseconds: 300),
              child: Material(
                shadowColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)
                  ),
                elevation: 6.0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: secondaryColor
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    elevation: 6.0,
                    color: Colors.transparent,
                    shadowColor: Colors.grey[50],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      splashColor: secondarySplashColor,
                      onTap: function,
                      child: Center(
                        child: Text(
                          "Tentar novamente",
                          style: TextStyle(
                            color: secondaryText,
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
        )
      ],
    );
  }
}