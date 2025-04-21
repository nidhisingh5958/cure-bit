import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Widget? titleWidget;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;

  const AppHeader({
    super.key,
    this.title = '',
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
    this.titleWidget,
    this.backgroundColor,
    this.foregroundColor,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: elevation,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor ?? theme.colorScheme.primary,
      leading: onBackPressed != null
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: foregroundColor ?? theme.colorScheme.primary,
              ),
              onPressed: onBackPressed,
            )
          : null,
      title: titleWidget ??
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: foregroundColor ?? theme.colorScheme.onSurface,
            ),
          ),
      actions: actions,
      toolbarHeight: height,
      automaticallyImplyLeading: onBackPressed != null,
      shape: elevation > 0
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
