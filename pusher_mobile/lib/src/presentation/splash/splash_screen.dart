import 'package:_imagineering_pack/setup/setup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorBackground,
      body: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child:
              CupertinoActivityIndicator(color: appColorText.withOpacity(.6)),
        ),
      ),
    );
  }
}
