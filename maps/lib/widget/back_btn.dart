import 'package:maps/constant/dimens.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyBackButton extends StatelessWidget {
  Function() onPressed;

  MyBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: Dimens.medium,
      top: Dimens.medium,
      child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(offset: Offset(2, 3), blurRadius: 18)]),
          child:
              IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back))),
    );
  }
}
