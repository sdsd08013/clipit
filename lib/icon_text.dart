import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  const IconText(
      {required this.text,
      required this.icon,
      required this.textColor,
      required this.iconColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              onTap.call();
            },
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(child: Icon(icon, color: iconColor, size: 14)),
                  TextSpan(text: " ", style: TextStyle(color: textColor)),
                  TextSpan(text: text, style: TextStyle(color: textColor))
                ],
              ),
            )));
  }
}
