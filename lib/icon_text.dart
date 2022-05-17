import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  IconText({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(child: Icon(icon, size: 20, color: color)),
          TextSpan(text: text, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
