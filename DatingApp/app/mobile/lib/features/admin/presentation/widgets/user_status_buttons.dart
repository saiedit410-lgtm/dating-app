import 'package:dating_app/features/admin/domain/user_status.dart';
import 'package:flutter/material.dart';

class UserStatusButtons extends StatelessWidget {
  const UserStatusButtons({
    required this.onSelected,
    super.key,
    this.isBusy = false,
  });

  final ValueChanged<UserStatus> onSelected;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    const List<UserStatus> statuses = <UserStatus>[
      UserStatus.active,
      UserStatus.suspended,
      UserStatus.banned,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((UserStatus status) {
        return OutlinedButton(
          onPressed: isBusy ? null : () => onSelected(status),
          child: Text(status.label),
        );
      }).toList(),
    );
  }
}
