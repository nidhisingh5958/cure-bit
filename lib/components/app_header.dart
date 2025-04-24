import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Widget? titleWidget;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final PreferredSizeWidget? bottom;

  const AppHeader({
    super.key,
    this.title = '',
    this.onBackPressed,
    this.onMenuPressed,
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
    this.titleWidget,
    this.backgroundColor,
    this.foregroundColor,
    this.height = kToolbarHeight,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: elevation,
      centerTitle: true,
      backgroundColor: backgroundColor ?? transparent,
      foregroundColor: foregroundColor ?? theme.colorScheme.primary,
      leading: onBackPressed != null
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: foregroundColor ?? black.withValues(alpha: .8),
              ),
              onPressed: onBackPressed,
            )
          : onMenuPressed != null
              ? IconButton(
                  onPressed: onMenuPressed,
                  icon: const Icon(Icons.menu),
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
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            )
          : null,
      titleTextStyle: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(height + bottomHeight);
  }
}
