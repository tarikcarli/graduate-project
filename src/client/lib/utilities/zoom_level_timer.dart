import 'package:flutter/foundation.dart';
import 'package:map_controller/map_controller.dart';
import 'dart:async';

class ZoomLevelTimer {
  ZoomLevelTimer({
    @required this.callback,
    @required this.statefulMapController,
    this.firstZoomLevelBorder = 12,
    this.secondZoomLevelBorder = 15,
    this.isZoomChange = 0,
  });
  Function callback;
  StatefulMapController statefulMapController;
  Timer timer;
  int firstZoomLevelBorder;
  int secondZoomLevelBorder;
  int isZoomChange;

  void startZoomTimer() {
    timer = Timer.periodic(
      Duration(milliseconds: 100),
      (timer) {
        if (statefulMapController.zoom >= secondZoomLevelBorder &&
            isZoomChange != 2) {
          print('_isZoomChange = 2');
          isZoomChange = 2;
          callback(isZoomChange);
        }
        if (statefulMapController.zoom < secondZoomLevelBorder &&
            statefulMapController.zoom > firstZoomLevelBorder &&
            isZoomChange != 1) {
          print('_isZoomChange = 1');
          isZoomChange = 1;
          callback(isZoomChange);
        }
        if (statefulMapController.zoom <= firstZoomLevelBorder &&
            isZoomChange != 0) {
          print('_isZoomChange = 0');
          isZoomChange = 0;
          callback(isZoomChange);
        }
      },
    );
  }

  void cancelZoomTimer() {
    timer.cancel();
  }
}
