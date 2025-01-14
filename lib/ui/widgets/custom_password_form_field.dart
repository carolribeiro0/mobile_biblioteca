import 'package:flutter/material.dart';

class CustomPasswordFormField extends StatefulWidget {
  final String labelText;
  final String? Function(String?)? validateFunction;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  CustomPasswordFormField({
    super.key,
    required this.labelText,
    this.validateFunction,
    this.controller,
    this.keyboardType,
  });

  @override
  State<CustomPasswordFormField> createState() => _CustomPassordFormFieldState();
}

class _CustomPassordFormFieldState extends State<CustomPasswordFormField> {
  late bool obscured = true;

  @override
  void initState() {
    super.initState();
    obscured = true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        validator: widget.validateFunction,
        obscureText: obscured,
        decoration: InputDecoration(
            suffixIconColor:  Theme.of(context).colorScheme.primary,
            suffixIcon: GestureDetector(
              onTap: () => {
                setState(() {
                  obscured = !obscured;
                })
              },
              child: obscured
                  ? Icon(Icons.remove_red_eye_rounded,)
                  : Icon(Icons.remove_red_eye_outlined),
            ),
            labelText: widget.labelText,
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(5),
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true
        ),
      ),
    );
  }
}