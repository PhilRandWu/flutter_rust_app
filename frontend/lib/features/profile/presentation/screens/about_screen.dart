import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).about)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Text(AppLocalizations.of(context).aboutText),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
