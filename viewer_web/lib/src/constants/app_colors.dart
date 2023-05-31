import 'package:_imagineering_pack/setup/setup.dart';
import 'package:flutter/material.dart';

class AppColors extends AppColorsBase {
  AppColors._();

  static final AppColors _instance = AppColors._();

  static AppColors get instance => _instance;

  @override
  Color get text => Colors.black;

  @override 
  Color get background => Colors.white;

  @override 
  Color get element => Colors.grey[100]!;

  @override 
  Color get primary => hexColor('00BDF9');

  @override
  Color get shimerHighlightColor => hexColor('#1C222C');

  @override
  Color get shimmerBaseColor => hexColor('#1C222C');

}
