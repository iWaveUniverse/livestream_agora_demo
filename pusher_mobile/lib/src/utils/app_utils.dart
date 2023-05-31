import 'package:_imagineering_pack/setup/setup.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; 

showSnackBar({context, required msg, Duration? duration}) {
  ScaffoldMessenger.of(context ?? Get.context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        style: w300TextStyle(color: appColorBackground),
      ),
      duration: duration ?? const Duration(seconds: 1),
      backgroundColor: appColorText,
    ),
  );
}
