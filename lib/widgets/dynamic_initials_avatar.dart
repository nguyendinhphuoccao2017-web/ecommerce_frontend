import 'package:flutter/material.dart';

class DynamicInitialsAvatar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final double radius;

  const DynamicInitialsAvatar({
    Key? key,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.radius = 20.0,
  }) : super(key: key);

  Color _getColorForName(String name) {
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final List<Color> colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.indigo, Colors.pink,
      Colors.cyan, Colors.brown
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }

    final String initials = '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
    final String fullName = '$firstName $lastName';
    final Color backgroundColor = _getColorForName(fullName);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
