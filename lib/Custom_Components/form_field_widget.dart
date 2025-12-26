import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Constants/app_color.dart';
import '../services/responsive.dart';

class FormFieldWidget extends StatelessWidget {
  final String? label;
  final String? subtitle;
  final bool isRequired;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final bool enabled;
  final double borderRadius;
  final Widget? prefixIcon;
  final Color? backgroundColor;
  final String? hintText;
  final String? Function(String?)? validator;
  final Widget? postfix;
  final bool obscureText;

  const FormFieldWidget({
    super.key,
    this.label = "NA",
    this.subtitle,
    required this.isRequired,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.controller,
    this.enabled = true,
    this.borderRadius = 12,
    this.prefixIcon,
    this.backgroundColor,
    this.hintText,
    this.validator,
    this.postfix,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != "NA")
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: r.font(13),
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppColors.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: r.font(12),
              color: AppColors.hintTextColor,
            ),
          ),
        ],
        const SizedBox(height: 6),
        TextFormField(
          enabled: enabled,
          style: TextStyle(
            fontSize: r.font(13),
            fontWeight: FontWeight.w400,
            color: AppColors.black,
          ),
          controller: controller,
          obscureText: obscureText,
          enableSuggestions: !obscureText,
          autocorrect: !obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.hintTextColor,
              fontSize: r.font(13),
              fontStyle: FontStyle.italic,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: postfix,
            fillColor: backgroundColor ?? AppColors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: enabled ? AppColors.secondaryColor : Colors.grey,
                width: 1.2,
              ),
            ),
            errorStyle: TextStyle(
              fontSize: r.font(11),
              color: AppColors.primaryColor,
            ),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: (value) {
            if (validator != null) return validator!(value);
            if (isRequired && enabled) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
