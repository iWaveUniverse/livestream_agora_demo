import 'package:_imagineering_pack/setup/setup.dart';
import 'package:_imagineering_pack/widgets/widget_ripple_button.dart';
import 'package:_imagineering_pack/widgets/widgets.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:agoralive/src/firestore_resources/constants.dart';
import 'package:agoralive/src/firestore_resources/instances.dart';
import 'package:agoralive/src/utils/utils.dart';
import 'dart:html' as html;

import '../auth/authenticate_screen.dart';
import '../widgets/widgets.dart';
import 'widgets/widget_live_viewer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFullScreen = false;
  double minimumWidth = 1280;

  double mainPadding(p) => isFullScreen
      ? 16
      : p.maxWidth - minimumWidth > 0
          ? (p.maxWidth - minimumWidth) / 2
          : 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setFriendlyRouteName(title: 'Gà Chiến TV', url: '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponLayout(
      computer: _computer(),
      tablet: _computer(),
      phone: _phone(),
    );
  }

  Widget _computer() {
    return Scaffold(
      body: LayoutBuilder(builder: (context, p) {
        return Column(
          children: [
            Container(
              height: 72,
              decoration: BoxDecoration(color: appColorBackground, boxShadow: [
                BoxShadow(color: appColorPrimary.withOpacity(.2), blurRadius: 8)
              ]),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: mainPadding(p)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  WidgetAppSVG(
                    assetsvg('chicken'),
                    height: 40,
                    color: appColorText,
                  ),
                  kSpacingWidth4,
                  Text(
                    'Gà Chiến TV',
                    style: w500TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  WidgetRippleButton(
                    onTap: () {
                      Get.dialog(const AuthenticateScreen());
                    },
                    color: appColorBackground,
                    child: Row(
                      children: [
                        Text(
                          'Đăng nhập',
                          style: w400TextStyle(fontSize: 15),
                        ),
                        kSpacingWidth4,
                        Icon(
                          Icons.login,
                          color: appColorText,
                          size: 18,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                      vertical: 16, horizontal: mainPadding(p)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight: Get.height - 32 - 72 - 40),
                          child: AspectRatio(
                            aspectRatio: 1920 / 1080,
                            child: WidgetLiveViewerBuilder(
                              isFullScreen: isFullScreen,
                              onPressFullScreen: () {
                                setState(() {
                                  isFullScreen = !isFullScreen;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      kSpacingWidth16,
                      Container(
                        width: 360,
                        height: Get.height - 32 - 72 - 40,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: appColorElement)),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: appColorElement,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    CupertinoIcons.chat_bubble,
                                    color: appColorText,
                                    size: 20,
                                  ),
                                  kSpacingWidth8,
                                  Text(
                                    'Chat',
                                    style: w400TextStyle(fontSize: 18),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(color: appColorBackground, boxShadow: [
                BoxShadow(color: appColorPrimary.withOpacity(.1), blurRadius: 8)
              ]),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: mainPadding(p)),
              child: Row(
                children: [
                  Text(
                    '© Copyright ${DateTime.now().year}',
                    style: w300TextStyle(),
                  ),
                  const Spacer(),
                  Text(
                    'Theo dõi thêm tại:',
                    style: w300TextStyle(),
                  ),
                  kSpacingWidth16,
                  WidgetAppSVG(
                    assetsvg('facebook'),
                    height: 18,
                  ),
                  kSpacingWidth8,
                  WidgetAppSVG(
                    assetsvg('youtube'),
                    height: 18,
                  ),
                  kSpacingWidth8,
                  WidgetAppSVG(
                    assetsvg('instagram'),
                    height: 18,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      floatingActionButton: SpeedDial(
        // animatedIcon: AnimatedIcons.menu_close,
        // animatedIconTheme: IconThemeData(size: 22.0),
        // / This is ignored if animatedIcon is non null
        // child: Text("open"),
        // activeChild: Text("close"),
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        mini: false,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,

        /// Transition Builder between label and activeLabel, defaults to FadeTransition.
        // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
        /// The below button size defaults to 56 itself, its the SpeedDial childrens size

        // overlayColor: Colors.black,
        // overlayOpacity: 0.5,
        onOpen: () => debugPrint('OPENING DIAL'),
        onClose: () => debugPrint('DIAL CLOSED'),
        useRotationAnimation: true,
        tooltip: 'Open Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        // foregroundColor: Colors.black,
        // backgroundColor: Colors.white,
        // activeForegroundColor: Colors.red,
        // activeBackgroundColor: Colors.blue,
        elevation: 8.0,
        animationCurve: Curves.elasticInOut,
        isOpenOnStart: false,
        shape: const StadiumBorder(),
        // childMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: [
          SpeedDialChild(
            child: !rmicons ? const Icon(Icons.accessibility) : null,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'First',
            onTap: () => setState(() => rmicons = !rmicons),
            onLongPress: () => debugPrint('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: !rmicons ? const Icon(Icons.brush) : null,
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            label: 'Second',
            onTap: () => debugPrint('SECOND CHILD'),
          ),
          SpeedDialChild(
            child: !rmicons ? const Icon(Icons.margin) : null,
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            label: 'Show Snackbar',
            visible: true,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(("Third Child Pressed")))),
            onLongPress: () => debugPrint('THIRD CHILD LONG PRESS'),
          ),
        ],
      ),
    );
  }

  bool rmicons = false;

  Widget _phone() {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: WidgetLiveViewerBuilder(
              isFullScreen: isFullScreen,
              onPressFullScreen: () {
                setState(() {
                  isFullScreen = !isFullScreen;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              width: 400,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  border: Border.all(color: appColorText.withOpacity(.2))),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: appColorBackground,
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 16,
                            color: appColorText.withOpacity(.2))
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Bình luận',
                          style: w400TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        WidgetRippleButton(
                          onTap: () {},
                          color: appColorBackground,
                          child: Row(
                            children: [
                              Text(
                                'Đăng nhập',
                                style: w400TextStyle(fontSize: 15),
                              ),
                              kSpacingWidth4,
                              Icon(
                                Icons.login,
                                color: appColorText,
                                size: 18,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
