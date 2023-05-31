import 'dart:math';

import 'package:_imagineering_pack/setup/setup.dart';
import 'package:_imagineering_pack/widgets/widgets.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agoralive/src/firestore_resources/constants.dart';
import 'package:agoralive/src/firestore_resources/instances.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetLiveViewerBuilder extends StatelessWidget {
  final bool isFullScreen;
  final VoidCallback onPressFullScreen;
  const WidgetLiveViewerBuilder(
      {super.key, required this.isFullScreen, required this.onPressFullScreen});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: StreamBuilder(
        stream: colConfigs.doc(kdb_live).snapshots(),
        builder: (context, snapshot) {
          Map data = snapshot.data == null ? {} : snapshot.data!.data() as Map;
          appDebugTrack(
              where: 'colConfigs.doc(kdb_live).snapshots', text: 'data: $data');
          return data.isEmpty || data[kdb_status] != kdb_streaming
              ? WidgetLiveViewerFake(
                  isOffline: data[kdb_status] != kdb_preparing,
                )
              : WidgetLiveViewer(
                  key: ValueKey(data[kdb_channelId]),
                  appId: data[kdb_appId],
                  channelId: data[kdb_channelId],
                  token: data[kdb_token],
                  countViewer: data[kdb_countViewer] ?? 0,
                  isFullScreen: isFullScreen,
                  onPressFullScreen: onPressFullScreen,
                );
        },
      ),
    );
  }
}

class WidgetLiveViewerFake extends StatelessWidget {
  final bool isOffline;
  const WidgetLiveViewerFake({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: appColorElement,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appColorElement)),
      child: Center(
        child: WidgetAppLottie(
          assetlottie(isOffline ? 'offline' : 'connecting'),
          width: 120,
        ),
      ),
    );
  }
}

class WidgetLiveViewer extends StatefulWidget {
  final String appId;
  final String channelId;
  final String token;
  final VoidCallback onPressFullScreen;
  final bool isFullScreen;
  final int countViewer;
  const WidgetLiveViewer({
    super.key,
    required this.appId,
    required this.channelId,
    required this.token,
    required this.onPressFullScreen,
    required this.isFullScreen,
    required this.countViewer,
  });

  @override
  State<WidgetLiveViewer> createState() => _WidgetLiveViewerState();
}

class _WidgetLiveViewerState extends State<WidgetLiveViewer> {
  @override
  void initState() {
    super.initState();
    initAgora();
  }

  late RtcEngine _engine;
  int? remoteId;

  Future<void> initAgora() async {
    //create the engine
    _engine = await RtcEngine.create(widget.appId);
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {},
        userJoined: (int uid, int elapsed) {
          appDebugTrack(where: 'userJoined', text: uid);
          setState(() {
            remoteId = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          appDebugTrack(where: 'userOffline', text: uid);
          setState(() {
            remoteId = null;
          });
          _engine.leaveChannel();
        },
      ),
    );
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(
        ClientRole.Audience,
        ClientRoleOptions(
            audienceLatencyLevel: AudienceLatencyLevelType.UltraLowLatency));
    await _engine.enableVideo();
    await _engine.muteLocalAudioStream(true);
    await _engine.muteLocalVideoStream(true);
    await _engine.joinChannel(
        widget.token,
        widget.channelId,
        null,
        Random().nextInt(100000) + 1,
        ChannelMediaOptions(
          publishLocalVideo: false,
          publishLocalAudio: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ));
  }

  @override
  void dispose() {
    _engine.destroy();
    super.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: appColorElement,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appColorElement)),
      child: remoteId != null
          ? Stack(
              alignment: Alignment.bottomRight,
              children: [
                RtcRemoteView.SurfaceView(
                  uid: remoteId!,
                  channelId: widget.channelId,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: widget.onPressFullScreen,
                    icon: Icon(
                      widget.isFullScreen
                          ? Icons.zoom_in_map_outlined
                          : Icons.zoom_out_map_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Row(
                    children: [
                      WidgetAppLottie(
                        assetlottie('live'),
                        width: 20,
                      ),
                      kSpacingWidth8,
                      const Icon(
                        Icons.remove_red_eye,
                        color: Colors.white,
                        size: 16,
                      ),
                      kSpacingWidth8,
                      Text(
                        '${widget.countViewer}',
                        style: w400TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          : Center(
              child: Center(
                child: WidgetAppLottie(
                  assetlottie('connecting'),
                  width: 120,
                ),
              ),
            ),
    );
  }
}
