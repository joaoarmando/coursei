import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  
  final stream;
  ErrorText(this.stream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(snapshot.hasError ? "${snapshot.error}" : "",
            style: TextStyle(
              color: Colors.red,
              fontSize: 14
            ),
          ),
        );
      }
    );
  }
}