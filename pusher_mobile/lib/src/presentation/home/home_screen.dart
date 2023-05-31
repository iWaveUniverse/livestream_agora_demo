import 'dart:async';

import 'package:_imagineering_pack/setup/setup.dart';
import 'package:_imagineering_pack/widgets/widgets.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agoralivepusher/src/firestore_resources/firestore_resources.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _localUserJoined = false;
  late RtcEngine _engine;

  int sizeWidth = 1920;
  int sizeHeight = 1080;

  String? msg;
  bool loading = false;
  final List<int> _users = [];

  bool started = false;

  String token = '';
  String channelId = '';
  String appId = '';

  @override
  void initState() {
    super.initState();
  }

  void switchCamera() {
    _engine.switchCamera();
  }

  Future<Map> _generateToken() async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('createCallsWithTokens');
      HttpsCallableResult resp = await callable.call();
      appDebugTrack(where: '_generateToken', text: resp.data);
      return resp.data['data'];
    } catch (e) {
      appDebugTrack(where: '_generateToken', text: e);
    }
    return {};
  }

  endLive() {
    colConfigs.doc(kdb_live).set({
      kdb_status: kdb_waiting,
    });
    _engine.leaveChannel();
    _engine.release();
    setState(() {
      _localUserJoined = false;
      started = false;
    });
  }

  Future<void> initAgora() async {
    setState(() {
      loading = true;
    });
    await colConfigs.doc(kdb_live).set({
      kdb_status: kdb_preparing,
    }, SetOptions(merge: true));
    await Future.delayed(const Duration(seconds: 3));
    Map tokenCreated = await _generateToken();
    if (tokenCreated.isEmpty) return;
    token = tokenCreated['token'];
    appId = tokenCreated['appId'];
    channelId = tokenCreated['channelId'];

    await colConfigs.doc(kdb_live).set({
      kdb_appId: appId,
      kdb_channelId: channelId,
      kdb_token: token,
      kdb_status: kdb_preparing,
      kdb_countViewer: 0,
    }, SetOptions(merge: true));

    try {
      // retrieve permissions
      await [Permission.microphone, Permission.camera].request();

      //create the engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine.setVideoEncoderConfiguration(VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: sizeWidth, height: sizeHeight),
        bitrate: bitrate,
        minBitrate: minBitrate,
        frameRate: 30,
        mirrorMode: VideoMirrorModeType.videoMirrorModeAuto,
        degradationPreference: DegradationPreference.maintainQuality,
      ));
      await _engine.setCameraCapturerConfiguration(CameraCapturerConfiguration(
        cameraDirection: CameraDirection.cameraRear,
        format: VideoFormat(width: sizeWidth, height: sizeHeight),
        followEncodeDimensionRatio: true,
      ));
      // await _engine.setVideoDenoiserOptions(
      //     true,
      //     const VideoDenoiserOptions(
      //         mode: VideoDenoiserMode.Auto,
      //         level: VideoDenoiserLevel.HighQuality));
      await _engine.enableVideo();
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            appDebugTrack(where: 'init agora userJoined', text: remoteUid);
            _users.add(remoteUid);
            setState(() {});
            colConfigs.doc(kdb_live).set({
              kdb_countViewer: _users.length,
            }, SetOptions(merge: true));
          },
          onUserOffline: (RtcConnection connection, int remoteUid, reason) {
            appDebugTrack(where: 'init agora userOffline', text: remoteUid);
            _users.remove(remoteUid);
            setState(() {});
            colConfigs.doc(kdb_live).set({
              kdb_countViewer: _users.length,
            }, SetOptions(merge: true));
          },
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            appDebugTrack(
                where: 'init agora joinChannelSuccess', text: connection);
            setState(() {
              _localUserJoined = true;
            });
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            appDebugTrack(where: 'init agora leaveChannel', text: stats);
            setState(() {
              _localUserJoined = false;
            });
          },
        ),
      );
      setState(() {});
      await _engine.joinChannel(
        token: token,
        channelId: channelId,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      colConfigs.doc(kdb_live).set({
        kdb_status: kdb_streaming,
      }, SetOptions(merge: true));

      setState(() {
        started = true;
        loading = false;
      });
    } catch (e) {
      appDebugTrack(where: 'init agora catch', text: e);
      await colConfigs.doc(kdb_live).set({
        kdb_status: kdb_waiting,
        kdb_countViewer: 0,
      });
      setState(() {
        msg = 'Can\'t start livestream, please try again!';
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    endLive();
  }

  int bitrate = 2400;
  int minBitrate = 800;
  int maxBitrate = 4000;
  int minFrameRate = 15;
  int frameRate = 30;

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start live stream'),
        actions: [
          IconButton(
            onPressed: switchCamera,
            icon: const Icon(
              Icons.camera_front_outlined,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appColorPrimary,
        onPressed: () {
          if (started) {
            endLive();
          } else {
            initAgora();
          }
        },
        child: Icon(
          !started ? Icons.play_arrow : Icons.stop,
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'minBitrate: $minBitrate',
                          style: w400TextStyle(),
                        ),
                        Text(
                          'bitrate: $bitrate',
                          style: w400TextStyle(),
                        ),
                        Text(
                          'minFrameRate: $minFrameRate',
                          style: w400TextStyle(),
                        ),
                        Text(
                          'frameRate: $frameRate',
                          style: w400TextStyle(),
                        ),
                        Text(
                          'viewers: ${_users.length}',
                          style: w400TextStyle(),
                        ),
                      ],
                    )),
                    SizedBox(
                      width: 200,
                      child: AspectRatio(
                        aspectRatio: sizeWidth / sizeHeight,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white24),
                          alignment: Alignment.center,
                          child: _localUserJoined
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AgoraVideoView(
                                    controller: VideoViewController(
                                      rtcEngine: _engine,
                                      canvas: const VideoCanvas(uid: 0),
                                    ),
                                  ),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ],
                ),
                kSpacingHeight20,
                Row(
                  children: [
                    Text(
                      'bitrate',
                      style: w400TextStyle(),
                    ),
                    kSpacingWidth24,
                    Expanded(
                      child: SfSlider(
                        min: minBitrate,
                        max: maxBitrate,
                        value: bitrate,
                        interval: 20,
                        showTicks: false,
                        showLabels: false,
                        enableTooltip: true,
                        minorTicksPerInterval: 1,
                        onChanged: (dynamic value) {
                          setState(() {
                            bitrate = value.toInt();
                          });
                          if (_debounce?.isActive ?? false) _debounce?.cancel();
                          _debounce =
                              Timer(const Duration(milliseconds: 2000), () {
                            _engine.setVideoEncoderConfiguration(
                                VideoEncoderConfiguration(
                              dimensions: VideoDimensions(
                                  width: sizeWidth, height: sizeHeight),
                              bitrate: bitrate,
                              minBitrate: minBitrate,
                              frameRate: 30,
                              mirrorMode:
                                  VideoMirrorModeType.videoMirrorModeAuto,
                              degradationPreference:
                                  DegradationPreference.maintainQuality,
                            ));
                          });
                        },
                      ),
                    )
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
          if (loading)
            const WidgetGlassBackground(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}


// import 'dart:async';

// import 'package:_imagineering_pack/setup/setup.dart';
// import 'package:_imagineering_pack/widgets/widgets.dart';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:agoralivepusher/src/firestore_resources/firestore_resources.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _localUserJoined = false;
//   late RtcEngine _engine;

//   int sizeWidth = 1920;
//   int sizeHeight = 1080;

//   String? msg;
//   bool loading = false;
//   final List<int> _users = [];

//   bool started = false;

//   String token = '';
//   String channelId = '';
//   String appId = '';

//   @override
//   void initState() {
//     super.initState();
//   }

//   void switchCamera() {
//     _engine.switchCamera();
//   }

//   Future<Map> _generateToken() async {
//     try {
//       HttpsCallable callable =
//           FirebaseFunctions.instance.httpsCallable('createCallsWithTokens');
//       HttpsCallableResult resp = await callable.call();
//       appDebugTrack(where: '_generateToken', text: resp.data);
//       return resp.data['data'];
//     } catch (e) {
//       appDebugTrack(where: '_generateToken', text: e);
//     }
//     return {};
//   }

//   endLive() {
//     colConfigs.doc(kdb_live).set({
//       kdb_status: kdb_waiting,
//     });
//     _engine.destroy();
//     setState(() {
//       _localUserJoined = false;
//       started = false;
//     });
//   }

//   Future<void> initAgora() async {
//     setState(() {
//       loading = true;
//     });
//     await colConfigs.doc(kdb_live).set({
//       kdb_status: kdb_preparing,
//     }, SetOptions(merge: true));
//     await Future.delayed(const Duration(seconds: 3));
//     Map tokenCreated = await _generateToken();
//     if (tokenCreated.isEmpty) return;
//     token = tokenCreated['token'];
//     appId = tokenCreated['appId'];
//     channelId = tokenCreated['channelId'];

//     await colConfigs.doc(kdb_live).set({
//       kdb_appId: appId,
//       kdb_channelId: channelId,
//       kdb_token: token,
//       kdb_status: kdb_preparing,
//       kdb_countViewer: 0,
//     }, SetOptions(merge: true));

//     try {
//       // retrieve permissions
//       await [Permission.microphone, Permission.camera].request();

//       //create the engine
//       _engine = await RtcEngine.create(appId);
//       await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//       await _engine.setClientRole(ClientRole.Broadcaster);
//       await _engine.setVideoEncoderConfiguration(VideoEncoderConfiguration(
//         dimensions: VideoDimensions(width: sizeWidth, height: sizeHeight),
//         bitrate: bitrate,
//         minBitrate: minBitrate,
//         frameRate: VideoFrameRate.Fps30,
//         minFrameRate: VideoFrameRate.Fps15,
//         mirrorMode: VideoMirrorMode.Enabled,
//         degradationPreference: DegradationPreference.MaintainQuality,
//       ));
//       await _engine.setCameraCapturerConfiguration(CameraCapturerConfiguration(
//         captureWidth: sizeWidth,
//         captureHeight: sizeHeight,
//       ));
//       // await _engine.setVideoDenoiserOptions(
//       //     true,
//       //     const VideoDenoiserOptions(
//       //         mode: VideoDenoiserMode.Auto,
//       //         level: VideoDenoiserLevel.HighQuality));
//       await _engine.enableVideo();
//       _engine.setEventHandler(
//         RtcEngineEventHandler(
//           userJoined: (uid, elapsed) {
//             appDebugTrack(where: 'init agora userJoined', text: uid);
//             _users.add(uid);
//             setState(() {});
//             colConfigs.doc(kdb_live).set({
//               kdb_countViewer: _users.length,
//             }, SetOptions(merge: true));
//           },
//           userOffline: (uid, reason) {
//             appDebugTrack(where: 'init agora userOffline', text: uid);
//             _users.remove(uid);
//             setState(() {});
//             colConfigs.doc(kdb_live).set({
//               kdb_countViewer: _users.length,
//             }, SetOptions(merge: true));
//           },
//           joinChannelSuccess: (String channel, int uid, int elapsed) {
//             appDebugTrack(where: 'init agora joinChannelSuccess', text: uid);
//             setState(() {
//               _localUserJoined = true;
//             });
//           },
//           leaveChannel: (stats) {
//             appDebugTrack(where: 'init agora leaveChannel', text: stats);
//             setState(() {
//               _localUserJoined = false;
//             });
//           },
//         ),
//       );
//       setState(() {});
//       await _engine.joinChannel(token, channelId, null, 0);

//       colConfigs.doc(kdb_live).set({
//         kdb_status: kdb_streaming,
//       }, SetOptions(merge: true));

//       setState(() {
//         started = true;
//         loading = false;
//       });
//     } catch (e) {
//       appDebugTrack(where: 'init agora catch', text: e);
//       await colConfigs.doc(kdb_live).set({
//         kdb_status: kdb_waiting,
//         kdb_countViewer: 0,
//       });
//       setState(() {
//         msg = 'Can\'t start livestream, please try again!';
//         loading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     endLive();
//   }

//   int bitrate = 3200;
//   int minBitrate = 1200;
//   int maxBitrate = 4000;
//   int minFrameRate = 15;
//   int frameRate = 30;

//   Timer? _debounce;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Start live stream'),
//         actions: [
//           IconButton(
//             onPressed: switchCamera,
//             icon: const Icon(
//               Icons.camera_front_outlined,
//             ),
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: appColorPrimary,
//         onPressed: () {
//           if (started) {
//             endLive();
//           } else {
//             initAgora();
//           }
//         },
//         child: Icon(
//           !started ? Icons.play_arrow : Icons.stop,
//           color: Colors.white,
//         ),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                         child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'minBitrate: $minBitrate',
//                           style: w400TextStyle(),
//                         ),
//                         Text(
//                           'bitrate: $bitrate',
//                           style: w400TextStyle(),
//                         ),
//                         Text(
//                           'minFrameRate: $minFrameRate',
//                           style: w400TextStyle(),
//                         ),
//                         Text(
//                           'frameRate: $frameRate',
//                           style: w400TextStyle(),
//                         ),
//                         Text(
//                           'viewers: ${_users.length}',
//                           style: w400TextStyle(),
//                         ),
//                       ],
//                     )),
//                     SizedBox(
//                       width: 200,
//                       child: AspectRatio(
//                         aspectRatio: sizeWidth / sizeHeight,
//                         child: Container(
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               color: Colors.white24),
//                           alignment: Alignment.center,
//                           child: _localUserJoined
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: const RtcLocalView.SurfaceView(),
//                                 )
//                               : const CircularProgressIndicator(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 kSpacingHeight20,
//                 Row(
//                   children: [
//                     Text(
//                       'bitrate',
//                       style: w400TextStyle(),
//                     ),
//                     kSpacingWidth24,
//                     Expanded(
//                       child: SfSlider(
//                         min: minBitrate,
//                         max: maxBitrate,
//                         value: bitrate,
//                         interval: 20,
//                         showTicks: false,
//                         showLabels: false,
//                         enableTooltip: true,
//                         minorTicksPerInterval: 1,
//                         onChanged: (dynamic value) {
//                           setState(() {
//                             bitrate = value.toInt();
//                           });
//                           if (_debounce?.isActive ?? false) _debounce?.cancel();
//                           _debounce =
//                               Timer(const Duration(milliseconds: 2000), () {
//                             _engine.setVideoEncoderConfiguration(
//                                 VideoEncoderConfiguration(
//                               dimensions: VideoDimensions(
//                                   width: sizeWidth, height: sizeHeight),
//                               bitrate: bitrate,
//                               minBitrate: minBitrate,
//                               frameRate: VideoFrameRate.Fps30,
//                               minFrameRate: VideoFrameRate.Fps15,
//                               mirrorMode: VideoMirrorMode.Enabled,
//                               degradationPreference:
//                                   DegradationPreference.MaintainQuality,
//                             ));
//                           });
//                         },
//                       ),
//                     )
//                   ],
//                 ),
//                 const Spacer(),
//               ],
//             ),
//           ),
//           if (loading)
//             const WidgetGlassBackground(
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
