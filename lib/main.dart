import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'preference_manager.dart';

void main() {
  runApp(MaterialApp(
    home: MapsPage(),
    theme: ThemeData(primaryColor: Colors.white),
  ));
}

/// Maps Page
///
class MapsPage extends StatefulWidget {
  @override
  State createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  final _textStyle = TextStyle(fontSize: 16.0, color: Colors.black87);
  final _drawerTextStyle = TextStyle(fontSize: 16.0, color: Colors.black87);
  final _preferenceManager = PreferenceManager();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _time = '', _address = '', _lat = 0.0, _lon = 0.0;
  List<String> _latList, _lonList, _timeList, _addressList = List<String>();
  GoogleMapController _mapController;

  void _refreshData() async {
    final time = await _preferenceManager.getTime() ?? '尚無停車紀錄';
    final address = await _preferenceManager.getAddress() ?? '點擊右下方按鈕即可紀錄停車位置';
    final lat = await _preferenceManager.getLatitude() ?? 23.973875;
    final lon = await _preferenceManager.getLongitude() ?? 120.982024;

    final latList = await _preferenceManager.getLatList() ?? List<String>();
    final lonList = await _preferenceManager.getLonList() ?? List<String>();
    final timeList = await _preferenceManager.getTimeList() ?? List<String>();
    final addressList =
        await _preferenceManager.getAddressList() ?? List<String>();

    setState(() {
      _time = time;
      _address = address;
      _lat = lat;
      _lon = lon;
      _animateCamera(_lat, _lon);

      _latList = latList;
      _lonList = lonList;
      _timeList = timeList;
      _addressList = addressList;
    });
  }

  @override
  void initState() {
    _refreshData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final infoSection = Container(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            '停車時間：' + (_time.length > 16 ? _time.substring(0, 16) : _time),
            style: _textStyle,
          ),
          Text(
            _address,
            style: _textStyle,
          ),
        ],
      ),
    );

    Widget floatingButton = FloatingActionButton(
        elevation: 4.0,
        backgroundColor: Colors.lightBlue,
        child: Icon(Icons.pin_drop),
        onPressed: _checkLocationPermission);

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      floatingButton =
          Positioned(child: floatingButton, top: 10.0, right: 10.0);
    } else {
      floatingButton =
          Positioned(child: floatingButton, bottom: 16.0, right: 16.0);
    }

    final drawerList = ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _addressList.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              _onHistoryItemClicked(index);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(_timeList[index].substring(0, 16),
                      style: _drawerTextStyle),
                  Text(_addressList[index], style: _drawerTextStyle)
                ],
              ),
            ),
          );
        });

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('定位小助手'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                _scaffoldKey.currentState.openEndDrawer();
              })
        ],
      ),
      endDrawer: Drawer(
        child: Scaffold(
            appBar: AppBar(
                elevation: 0.0,
                automaticallyImplyLeading: false,
                title: const Text('歷史紀錄')),
            body: drawerList),
      ),
      body: Column(
        children: <Widget>[
          infoSection,
          Expanded(
            child: Stack(
              children: <Widget>[
                GoogleMap(onMapCreated: _onMapCreated),
                floatingButton
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    bool isPermissionGranted =
        await SimplePermissions.checkPermission(Permission.AccessFineLocation);
    setState(() {
      _mapController = controller;
      if (isPermissionGranted) {
        _mapController
            .updateMapOptions(GoogleMapOptions(myLocationEnabled: true));
      }
      _animateCamera(_lat, _lon);
    });
  }

  void _checkLocationPermission() async {
    PermissionStatus status = await SimplePermissions.getPermissionStatus(
        Permission.AccessFineLocation);
    switch (status) {
      case PermissionStatus.authorized:
        _recordUserLocation();
        break;
      case PermissionStatus.denied:
      case PermissionStatus.notDetermined:
        status = await SimplePermissions.requestPermission(
            Permission.AccessFineLocation);
        if (status == PermissionStatus.authorized) {
          _recordUserLocation();
        }
        break;
      default:
        break;
    }
  }

  void _recordUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    List<Placemark> places = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    await _preferenceManager.setPosition(
        position.latitude, position.longitude, true);
    await _preferenceManager.setTime(DateTime.now().toString(), true);
    if (places.isNotEmpty) {
      await _preferenceManager.setAddress(
          places.first.subAdministratieArea +
              places.first.locality +
              places.first.thoroughfare +
              places.first.subThoroughfare,
          true);
    }
    _refreshData();
  }

  void _animateCamera(double lat, double lon) {
    if (_mapController == null) return;
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lon), zoom: 17)));
    _mapController.clearMarkers();
    _mapController.addMarker(MarkerOptions(
        position: LatLng(lat, lon),
        infoWindowText: InfoWindowText("停車位置", null)));
  }

  void _onHistoryItemClicked(int index) async {
    await _preferenceManager.setPosition(
        double.parse(_latList[index]), double.parse(_lonList[index]), false);
    await _preferenceManager.setTime(_timeList[index], false);
    await _preferenceManager.setAddress(_addressList[index], false);
    _refreshData();
  }
}
