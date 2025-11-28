import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/themes/app_theme.dart';
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
  const RootScreen({super.key});

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
        backgroundColor: AppTheme.lightTheme.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.green,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Row(
        children: [if (isLargeScreen) _buildNavigationRail(selectedIndex)],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : _buildBottomNavigationBar(selectedIndex),
    );
  }

  Widget _buildNavigationRail(int selectedIndex) {
    return NavigationRail(
      backgroundColor: AppTheme.lightTheme.primaryColor,
      unselectedLabelTextStyle: const TextStyle(color: Colors.white),
      selectedLabelTextStyle: const TextStyle(color: Colors.blue),
      selectedIconTheme: const IconThemeData(color: Colors.blue),
      unselectedIconTheme: const IconThemeData(color: Colors.white),
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
      children: const [
        Text('Really', style: TextStyle(color: Colors.white)),
        Text('Stick', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
