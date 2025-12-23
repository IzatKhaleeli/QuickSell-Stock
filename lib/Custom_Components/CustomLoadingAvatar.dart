import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Constants/app_color.dart';
import '../services/responsive.dart';

void showLoadingAvatar(
  BuildContext context,
) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (BuildContext dialogContext) {
      final r = Responsive(dialogContext);
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(r.scale(10)),
              child: SizedBox(
                width: r.scale(160),
                height: r.scale(120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitFadingCircle(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index.isEven
                                ? AppColors.secondaryColor
                                : AppColors.lowSecondaryColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  await Future.delayed(const Duration(seconds: 1));
}
