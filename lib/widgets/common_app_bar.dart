import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  
  const CommonAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      leading: showBackButton 
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Safely navigate back or go to home if we can't go back
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/home');
              }
            },
          )
        : null,
      actions: [
        // Home icon button - always show it on every screen
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            // Navigate to home screen
            context.go('/home');
          },
        ),
        // Add any additional actions passed to the widget
        if (actions != null) ...actions!,
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
