import 'package:flutter/widgets.dart';

class CustomMulitColorText extends StatelessWidget {
  final TextStyle? textStyle;
  final List<Map<String, Color>> textColorList;

  const CustomMulitColorText({
    super.key,

    required this.textStyle,
    required this.textColorList,
  });

  @override
  Widget build(BuildContext context) {
    if (textColorList.isEmpty) {
      return SizedBox.shrink();
    }

    return RichText(
      text: TextSpan(
        children: textColorList.map((textColor) {
          String text = textColor.keys.first;
          Color? color = textColor[text];
          return TextSpan(
            text: text,
            style: textStyle?.copyWith(color: color),
          );
        }).toList(),
      ),
    );
  }
}
