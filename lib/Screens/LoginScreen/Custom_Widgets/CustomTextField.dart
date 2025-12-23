import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  final Color textColor; // Color for text (required)
  final Color hintColor; // Color for hint text (required)
  final Color iconColor; // Color for icon (required)
  final Color borderColor; // Color for the border (required)
  final Color fillColor; // Color for the fill (required)
  final Color backgroundColor; // Color for background (required)

  const CustomTextField({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    required this.onChanged,
    required this.textColor,
    required this.hintColor,
    required this.iconColor,
    required this.borderColor,
    required this.fillColor,
    required this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText; // Initially uses the value from widget
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured; // Toggle the obscured state
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.85, 1.2);

    final textStyle = TextStyle(
      fontSize: 16 * scale,
      color: widget.textColor,
      fontFamily: 'NotoSansUI',
    );
    final hintStyle = TextStyle(
      color: widget.hintColor,
      fontSize: 13,
    );
    final iconColor = widget.iconColor;
    final fillColor = widget.fillColor;
    final backgroundColor = widget.backgroundColor;
    final borderColor = widget.borderColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8 * scale),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 5 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: TextField(
        obscureText: _isObscured,
        onChanged: widget.onChanged,
        style: textStyle,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: hintStyle,
          prefixIcon: Icon(widget.icon, color: iconColor, size: 24 * scale),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    size: 24 * scale,
                  ),
                  color: iconColor,
                  onPressed: _togglePasswordVisibility,
                )
              : null,
          filled: true,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * scale),
            borderSide: BorderSide(color: Colors.transparent, width: 0),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 18.0 * scale,
            horizontal: 16.0 * scale,
          ),
        ),
      ),
    );
  }
}
