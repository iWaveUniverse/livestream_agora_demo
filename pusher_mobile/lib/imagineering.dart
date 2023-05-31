import 'package:_imagineering_pack/setup/app_base.dart';
import 'package:_imagineering_pack/setup/app_setup.dart';
import 'package:agoralivepusher/src/constants/constants.dart';
import 'package:agoralivepusher/src/utils/utils.dart';
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
 