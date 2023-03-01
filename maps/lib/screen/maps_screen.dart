import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:maps/constant/text_style.dart';
import '../constant/dimens.dart';
import '../gen/assets.gen.dart';

class CurentWidgetState {
  CurentWidgetState._();

  static const stateSelectOrigin = 0;
  static const stateSelectDestination = 1;
  static const stateReqDriver = 2;
}

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({Key? key}) : super(key: key);

  @override
  State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  List curentWidgetList = [CurentWidgetState.stateSelectOrigin];
  String distance = "در حال محاسبه فاصله...";
  String originAddress = "مبدا";
  String destAddress = "مقصد";
  List<GeoPoint> geoPoint = [];
  Widget markerIcon = SvgPicture.asset(
    Assets.icons.origin,
    width: 100,
    height: 40,
  );
  Widget originMarker = SvgPicture.asset(
    Assets.icons.origin,
    width: 100,
    height: 40,
  );
  Widget destMarker = SvgPicture.asset(
    Assets.icons.destination,
    width: 100,
    height: 40,
  );

  MapController mapController = MapController(
      initMapWithUserPosition: false,
      initPosition:
          GeoPoint(latitude: 37.4417208603, longitude: -122.0812335509));
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: OSMFlutter(
              controller: mapController,
              trackMyPosition: true,
              initZoom: 15,
              isPicker: true,
              mapIsLoading: const SpinKitCircle(color: Colors.black),
              minZoomLevel: 8,
              maxZoomLevel: 18,
              stepZoom: 1,
              markerOption: MarkerOption(
                  advancedPickerMarker: MarkerIcon(
                iconWidget: markerIcon,
              )),
            ),
          ),
          currentWidget(),
          Positioned(
            left: Dimens.medium,
            top: Dimens.medium,
            child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(offset: Offset(2, 3), blurRadius: 18)
                    ]),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    switch (curentWidgetList.last) {
                      case CurentWidgetState.stateSelectOrigin:
                        break;
                      case CurentWidgetState.stateSelectDestination:
                        mapController.advancedPositionPicker();

                        mapController.removeMarker(geoPoint.last);
                        markerIcon = SvgPicture.asset(
                          Assets.icons.origin,
                          width: 100,
                          height: 40,
                        );

                        geoPoint.removeLast();
                        break;
                      case CurentWidgetState.stateReqDriver:
                        mapController.advancedPositionPicker();
                        mapController.removeMarker(geoPoint.last);
                        geoPoint.removeLast();
                        markerIcon = destMarker;
                        break;
                    }

                    setState(() {
                      curentWidgetList.removeLast();
                    });
                  },
                )),
          )
        ],
      ),
    ));
  }

  Widget currentWidget() {
    Widget widget = origin();
    switch (curentWidgetList.last) {
      case CurentWidgetState.stateSelectOrigin:
        widget = origin();
        break;
      case CurentWidgetState.stateSelectDestination:
        widget = dest();
        break;
      case CurentWidgetState.stateReqDriver:
        widget = reqDriver();
        break;
    }
    return widget;
  }

  Widget origin() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
            onPressed: () async {
              GeoPoint originPoint = await mapController
                  .getCurrentPositionAdvancedPositionPicker();
              log(originPoint.latitude);
              print(originPoint.latitude);
              geoPoint.add(originPoint);
              markerIcon = destMarker;
              setState(() {
                curentWidgetList.add(CurentWidgetState.stateSelectDestination);
              });
              mapController.init();
            },
            child: Text(
              "انتخاب مبدا",
              style: MyTextStyle.button,
            )),
      ),
    );
  }

  Widget dest() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
            onPressed: () async {
              await mapController
                  .getCurrentPositionAdvancedPositionPicker()
                  .then(
                (value) {
                  geoPoint.add(value);
                },
              );
              mapController.cancelAdvancedPositionPicker();
              await mapController.addMarker(geoPoint.first,
                  markerIcon: MarkerIcon(
                    iconWidget: originMarker,
                  ));
              await mapController.addMarker(geoPoint.last,
                  markerIcon: MarkerIcon(
                    iconWidget: destMarker,
                  ));

              setState(() {
                curentWidgetList.add(CurentWidgetState.stateReqDriver);
              });

              distance2point(geoPoint.first, geoPoint.last).then((value) {
                setState(() {
                  if (value < 1000) {
                    distance = "فاصله مبدا تا مقصد ${value.toInt()} متر";
                  } else {
                    distance = "فاصله مبدا تا مقصد ${value ~/ 1000} کیلومتر";
                  }
                });
              });

              await getAdres();
            },
            child: Text(
              "انتخاب مقصد",
              style: MyTextStyle.button,
            )),
      ),
    );
  }

  Widget reqDriver() {
    mapController.zoomOut();
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: Column(
          children: [
            Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.medium),
                color: Colors.white,
              ),
              child: Center(
                  child: Text(
                distance,
                style: MyTextStyle.button,
              )),
            ),
            SizedBox(
              height: Dimens.small,
            ),
            Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.medium),
                color: Colors.white,
              ),
              child: Center(
                  child: Text(
                originAddress,
                style: MyTextStyle.button,
              )),
            ),
            SizedBox(
              height: Dimens.small,
            ),
            Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.medium),
                color: Colors.white,
              ),
              child: Center(
                  child: Text(
                destAddress,
                style: MyTextStyle.button,
              )),
            ),
            SizedBox(
              height: Dimens.small,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {},
                  child: Center(
                    child: Text(
                      "درخواست راننده",
                      style: MyTextStyle.button,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  getAdres() async {
    try {
      await placemarkFromCoordinates(
              geoPoint.last.latitude, geoPoint.last.longitude,
              localeIdentifier: "fa")
          .then((List<Placemark> plist) {
        setState(() {
          destAddress =
              "${plist.first.locality} ${plist.first.thoroughfare} ${plist[2].name}";
        });
      });

      await placemarkFromCoordinates(
              geoPoint.first.latitude, geoPoint.first.longitude,
              localeIdentifier: "fa")
          .then((List<Placemark> plist) {
        setState(() {
          originAddress =
              "${plist.first.locality} ${plist.first.thoroughfare} ${plist[2].name}";
        });
      });
    } catch (e) {
      print("دلیلش چیه؟" + e.toString());
      destAddress = "آدرس یافت نشد";
      originAddress = "آدرس یافت نشد";
    }
  }
}
