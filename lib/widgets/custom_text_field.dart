import 'package:flutter/material.dart';

import '../appColors.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final Icon icon;
  final Function(String) changed;
  final bool obscure;
  final TextInputType keyboardType;
  final double height;
  final Function(String) validator;
  final GlobalKey<FormState> formKey;
  CustomTextField({@required this.hint, this.icon, @required this.changed, 
    @required this.obscure, this.keyboardType, this.height,this.validator,this.formKey});

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  
  @override
  Widget build(BuildContext context) {
    double height = widget.height == null ? 50 : widget.height;
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        width: MediaQuery.of(context).size.width * .8,
        height: height,
        decoration: BoxDecoration(
          color: greyBackground,
          borderRadius: BorderRadius.circular(10)
        ),
        child: TextFormField(
          key: widget.formKey,
          onChanged: (s){
            widget.changed(s);
            if (widget.formKey != null){
              widget.formKey.currentState.validate();
            }
            
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 20),
            suffixIcon: widget.icon,
          ),
          style: TextStyle(color: primaryText, fontSize: 20, fontWeight: FontWeight.w600),
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
        ),
      );
  }
}