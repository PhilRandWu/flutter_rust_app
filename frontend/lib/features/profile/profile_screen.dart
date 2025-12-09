import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/themes/app_theme.dart';

enum SettingsOption { language, theme, devices, about }

class IconWithWarning extends StatelessWidget {
  final IconData iconData;
  final bool shouldBeWarning;

  const IconWithWarning({
    super.key,
    required this.iconData,
    required this.shouldBeWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(iconData),
        if (shouldBeWarning)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SettingsOption _selectedOption;

  @override
  void initState() {
    _selectedOption = SettingsOption.theme;
    super.initState();
  }

  void _selectOption(SettingsOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  Widget _buildContent() {
    switch (_selectedOption) {
      case SettingsOption.language:
        return Text("language");
      case SettingsOption.theme:
        return Text("theme");
      case SettingsOption.devices:
        return Text("devices");
      case SettingsOption.about:
        return Text("about");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Text(
                    "Settings",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildNavItem(
                        label: "language",
                        icon: Icons.language,
                        option: SettingsOption.language,
                      ),
                      _buildNavItem(
                        label: "theme",
                        icon: Icons.color_lens,
                        option: SettingsOption.theme,
                      ),
                      _buildNavItem(
                        label: "devices",
                        icon: Icons.devices,
                        option: SettingsOption.devices,
                      ),
                      _buildNavItem(
                        label: "about",
                        icon: Icons.info,
                        option: SettingsOption.about,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required SettingsOption option,
    bool hasWarning = false,
  }) {
    final isSelected = _selectedOption == option;
    return ListTile(
      title: Text(label),
      leading: hasWarning
          ? IconWithWarning(iconData: icon, shouldBeWarning: true)
          : Icon(icon),
      selected: isSelected,
      selectedTileColor: AppColors.secondaryLight.withOpacity(0.1),
      selectedColor: AppTheme.lightTheme.primaryColor,
      onTap: () => _selectOption(option),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
