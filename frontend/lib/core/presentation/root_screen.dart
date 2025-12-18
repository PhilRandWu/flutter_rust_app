import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/core/themes/extensions.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class NavigationItem {
  final String label;
  final String route;
  final IconData unselectedIcon;
  final IconData selectedIcon;

  const NavigationItem({
    required this.label,
    required this.route,
    required this.unselectedIcon,
    required this.selectedIcon,
  });
}

const List<NavigationItem> _navigationItems = [
  NavigationItem(
    label: 'Profile',
    route: '/profile',
    unselectedIcon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

class RootScreen extends StatefulWidget {
  final Widget child;
  const RootScreen({super.key, required this.child});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  void _onItemTapped(int index) {
    if (index >= 0 && index < _navigationItems.length) {
      GoRouter.of(context).go(_navigationItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 800;
    final int selectedIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: _AppBarTitle(),
        backgroundColor: context.colors.primary,
      ),
      body: Row(
        children: [
          if (isLargeScreen)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.primary, context.colors.secondary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _buildNavigationRail(selectedIndex),
            ),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : _buildBottomNavigationBar(selectedIndex),
    );
  }

  Widget _buildNavigationRail(int selectedIndex) {
    return NavigationRail(
      backgroundColor: Colors.transparent,
      indicatorColor: context.colors.background,
      useIndicator: true,
      unselectedLabelTextStyle: TextStyle(
        color: context.colors.textOnPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      selectedLabelTextStyle: TextStyle(
        color: context.colors.textOnPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      selectedIconTheme: IconThemeData(color: context.colors.primary, size: 24),
      unselectedIconTheme: IconThemeData(
        color: context.colors.textOnPrimary,
        size: 22,
      ),
      groupAlignment: 0.0,
      selectedIndex: selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      destinations: _navigationItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.unselectedIcon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.label),
            ),
          )
          .toList(),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _buildSettingsButton(),
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: IconButton(
        onPressed: () {
          context.go(AppRoutes.profile);
        },
        icon: const Icon(Icons.settings),
        iconSize: 24,
        color: context.colors.textOnPrimary,
        selectedIcon: Icon(
          Icons.settings,
          color: context.colors.primary
        ),
        tooltip: 'Settings',
        splashRadius: 24,
        hoverColor: context.colors.primary.withOpacity(0.1),
        splashColor: context.colors.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildBottomNavigationBar(int selectIndex) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) => states.contains(WidgetState.selected)
              ? const IconThemeData(color: Colors.blue) // 选中态：蓝色图标
              : const IconThemeData(color: Colors.white), // 未选中态：白色图标
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) => states.contains(WidgetState.selected)
              ? const TextStyle(color: Colors.blue) // 选中态：蓝色文字
              : const TextStyle(color: Colors.white), // 未选中态：白色文字
        ),
      ),
      child: NavigationBar(
        // backgroundColor: AppTheme.lightTheme.primaryColor,
        indicatorColor: Colors.white,
        selectedIndex: selectIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _navigationItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.unselectedIcon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [_buildAppName(context), Spacer(), _buildLogoutButton(context)],
    );
  }

  Widget _buildAppName(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.go(AppRoutes.home);
      },
      child: Row(
        children: [
          Text(
            'Really',
            style: context.typographies.headingSmall.copyWith(
              color: context.colors.background,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Stick',
            style: context.typographies.headingSmall.copyWith(
              color: context.colors.hint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Successfully logged out")));
          context.go(AppRoutes.unauthenticatedHome);
        }
      },
      child: ElevatedButton(
        onPressed: () {
          BlocProvider.of<AuthBloc>(context).add(AuthLogoutRequested());
        },
        style: context.styles.buttonMedium,
        child: Text("Logout"),
      ),
    );
  }
}
