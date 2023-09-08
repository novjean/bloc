import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../utils/constants.dart';

class LoadingWidget extends StatelessWidget{
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitWave(
        itemBuilder: (BuildContext context, int index) {
          return const DecoratedBox(
            decoration: BoxDecoration(
              color: Constants.primary,
            ),
          );
        },
      ),
    );
  }

}