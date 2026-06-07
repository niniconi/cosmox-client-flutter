import 'package:flutter/material.dart';

class InputFormField extends StatelessWidget {
  final String? labelText;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final bool autoFocus;
  final bool obscureText;
  final Icon? icon;
  final Widget? suffixIcon;
  final int maxLines;
  final String? helpText;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;
  const InputFormField({
    super.key,
    this.labelText,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.controller,
    this.autoFocus = false,
    this.obscureText = false,
    this.icon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.helpText,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autoFocus,
      onChanged: onChanged,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        icon: icon,
        labelText: labelText,
        helperText: helpText,
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String? labelText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool obscureText;
  final Icon? icon;
  const InputField({
    super.key,
    this.labelText,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autoFocus = false,
    this.obscureText = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autoFocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      decoration: InputDecoration(
        icon: icon,
        labelText: labelText,
        errorText: errorText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class FormButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const FormButton({super.key, this.text = '', this.onPressed});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: screenHeight * .02),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
