import 'package:_imagineering_pack/setup/app_base.dart';
import 'package:_imagineering_pack/setup/app_setup.dart';
import 'package:agoralive/src/constants/constants.dart';
import 'package:agoralive/src/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';

imagineeringSetup() {
  AppSetup.initialized(
    value: AppSetup(
      env: AppEnv.preprod,
      appColors: AppColors.instance,
      appPrefs: AppPrefs.instance,
    ),
  );
}

const FirebaseOptions firebaseOptionsPREPROD = FirebaseOptions(
  apiKey: "AIzaSyDhuxDOSElN3TYtAzn6omaQK8tH4CpPXxw",
  authDomain: "agoralive-banga.firebaseapp.com",
  projectId: "agoralive-banga",
  storageBucket: "agoralive-banga.appspot.com",
  messagingSenderId: "241716564029",
  appId: "1:241716564029:web:011ea99976ec37fec2da54",
  measurementId: "G-YH8G0FM5C5",
);
