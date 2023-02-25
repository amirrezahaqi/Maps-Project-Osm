import 'package:flutter/material.dart';

import 'package:maps/constant/text_style.dart';

import '../constant/dimens.dart';
import '../widget/back_btn.dart';

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({super.key});

  @override
  State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 82, 90, 82),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(Dimens.large),
              child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "انتخاب مبدا",
                    style: MyTextStyle.button,
                  )),
            ),
          ),
          MyBackButton(
            onPressed: () {},
          )
        ],
      ),
    ));
  }
}
