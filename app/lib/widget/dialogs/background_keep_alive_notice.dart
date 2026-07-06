import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/widget/dialogs/custom_bottom_sheet.dart';
import 'package:routerino/routerino.dart';

class BackgroundKeepAliveNotice extends StatelessWidget {
  const BackgroundKeepAliveNotice({super.key});

  static Future<void> open(BuildContext context) async {
    if (checkPlatformIsDesktop()) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t.dialogs.backgroundKeepAliveNotice.title),
          content: Text(t.dialogs.backgroundKeepAliveNotice.content),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(t.general.close),
            ),
          ],
        ),
      );
    } else {
      await context.pushBottomSheet(() => const BackgroundKeepAliveNotice());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: t.dialogs.backgroundKeepAliveNotice.title,
      description: t.dialogs.backgroundKeepAliveNotice.content,
      child: Center(
        child: ElevatedButton(
          onPressed: () => context.popUntilRoot(),
          child: Text(t.general.close),
        ),
      ),
    );
  }
}