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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: errorText != null ? Colors.red : Colors.grey,
                  fontSize: 11,
                  fontFamily: 'Metropolis',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      obscureText: isPassword,
                      onChanged: onChanged,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Metropolis',
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (showGreenTick)
                    Image.asset('assets/images/icon/green-tick.png', width: 24, height: 24),
                  if (showRedTick || errorText != null)
                    Image.asset('assets/images/icon/red-tick.png', width: 24, height: 24, color: Colors.red),
                ],
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
