import 'package:dating_app/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Verification queue'),
            onTap: () =>
                context.pushNamed(AppRoute.adminVerifications.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: const Text('Reports queue'),
            onTap: () => context.pushNamed(AppRoute.adminReports.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Audit log'),
            onTap: () => context.pushNamed(AppRoute.adminAudit.routeName),
          ),
        ],
      ),
    );
  }
}
