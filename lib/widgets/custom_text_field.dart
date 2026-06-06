import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final String? errorText;
  final bool showGreenTick;
  final bool showRedTick;
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '',
    this.isPassword = false,
    this.errorText,
    this.showGreenTick = false,
    this.showRedTick = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: errorText != null ? Border.all(color: Colors.red) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: isPassword,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Metropolis',
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(
                      color: errorText != null ? Colors.red : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Metropolis',
                    ),
                    floatingLabelStyle: TextStyle(
                      color: errorText != null ? Colors.red : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Metropolis',
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (showGreenTick)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image.asset('assets/images/icon/green-tick.png', width: 24, height: 24),
                ),
              if (showRedTick || errorText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image.asset('assets/images/icon/red-tick.png', width: 24, height: 24, color: Colors.red),
                ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 20),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontFamily: 'Metropolis',
              ),
            ),
          ),
      ],
    );
  }
}
