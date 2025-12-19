import 'package:flutter/cupertino.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // children: [Image.asset('', width: 80, height: 80)],
      children: [
        Text('logo png')
      ],
    );
  }
}
