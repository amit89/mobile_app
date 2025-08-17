import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/common_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Check if user is authenticated and redirect to login if not
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Only show profile info when authenticated
    // The user will be redirected to login from initState if not authenticated
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              'Mobile: ${authProvider.mobile}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${authProvider.email}',
              style: const TextStyle(fontSize: 16),
            ),
            if (authProvider.isAdmin) ...[
              const SizedBox(height: 32),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Panel'),
                subtitle: const Text('Manage products and categories'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.go('/admin');
                },
              ),
              const Divider(),
            ],
          ],
        ),
      ),
    );
  }
}