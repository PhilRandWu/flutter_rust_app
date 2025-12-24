import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/icon_with_warning.dart';
import 'package:frontend/features/profile/screen/about_screen.dart';
import 'package:frontend/features/profile/screen/device_screen.dart';
import 'package:frontend/features/profile/screen/theme_selection_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';

import 'language_selection_screen.dart';

enum SettingsOption { language, theme, devices, about }

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
        return LocaleSelectionScreen();
      case SettingsOption.theme:
        return ThemeSelectionScreen();
      case SettingsOption.devices:
        return DeviceScreen();
      case SettingsOption.about:
        return AboutScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Text(
                    AppLocalizations.of(context).profileSettings,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      // color: AppThemeColors.textPrimary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildNavItem(
                        label: AppLocalizations.of(context).language,
                        icon: Icons.language,
                        option: SettingsOption.language,
                      ),
                      _buildNavItem(
                        label: AppLocalizations.of(context).theme,
                        icon: Icons.color_lens,
                        option: SettingsOption.theme,
                      ),
                      _buildNavItem(
                        label: AppLocalizations.of(context).devices,
                        icon: Icons.devices,
                        option: SettingsOption.devices,
                      ),
                      _buildNavItem(
                        label: AppLocalizations.of(context).about,
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
      // selectedTileColor: AppThemeColors.secondaryLight.withOpacity(0.1),
      // selectedColor: AppTheme.lightTheme.primaryColor,
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
