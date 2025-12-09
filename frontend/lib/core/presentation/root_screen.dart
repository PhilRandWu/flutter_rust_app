import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/features/profile/profile_screen.dart';
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

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.statusBarColor,
        systemNavigationBarColor: AppColors.systemNavigationBarColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: _AppBarTitle(),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.systemNavigationBarColor,
        ),
        elevation: 2,
        shadowColor: AppColors.opacity10,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Row(
          children: [
            if (isLargeScreen) _buildNavigationRail(selectedIndex),
            Expanded(child: widget.child),
          ],
        ),
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : _buildBottomNavigationBar(selectedIndex),
    );
  }

  Widget _buildNavigationRail(int selectedIndex) {
    return NavigationRail(
      backgroundColor: AppColors.navigationBackground,
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.navigationUnselected,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.navigationSelectedText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      selectedIconTheme: IconThemeData(
        color: AppColors.navigationSelectedIcon,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: AppColors.navigationUnselected,
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
        color: AppColors.navigationUnselected,
        selectedIcon: Icon(
          Icons.settings,
          color: AppColors.navigationSelectedIcon,
        ),
        tooltip: 'Settings',
        splashRadius: 24,
        hoverColor: AppColors.secondaryLight.withOpacity(0.1),
        splashColor: AppColors.secondaryLight.withOpacity(0.3),
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
        backgroundColor: AppTheme.lightTheme.primaryColor,
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
      children: [_buildAppName(), Spacer(), _buildLogoutButton(context)],
    );
  }

  Widget _buildAppName() {
    return Row(
      children: [
        Text(
          'Really',
          style: TextStyle(
            color: AppColors.textInverse,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Stick',
          style: TextStyle(
            color: AppColors.secondaryLight,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
        child: Text("Logout"),
      ),
    );
  }
}
