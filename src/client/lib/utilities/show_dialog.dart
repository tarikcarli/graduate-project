import 'package:business_travel/widgets/dialog_widget.dart';
import 'package:business_travel/widgets/dialog_widget_with_cancel.dart';
import 'package:flutter/material.dart';

class CustomDialog {
  static Future<bool> show({
    @required BuildContext ctx,
    @required bool withCancel,
    @required String title,
    @required String content,
    bool success = false,
  }) async {
    bool result;
    if (withCancel) {
      result = await showDialog<bool>(
        barrierDismissible: false,
        context: ctx,
        builder: (context) => DialogWidgetWithCancel(
          onPressedOk: () {
            Navigator.of(context).pop(true);
          },
          onPressedCancel: () {
            Navigator.of(context).pop(false);
          },
          title: title,
          content: content,
        ),
      );
    } else {
      result = await showDialog<bool>(
        barrierDismissible: false,
        context: ctx,
        builder: (context) => DialogWidget(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          title: title,
          content: content,
          success: success,
        ),
      );
    }
    return result;
  }
}
