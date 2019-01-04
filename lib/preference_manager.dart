import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  static final PreferenceManager _instance = new PreferenceManager._internal();

  static const KEY_LAT = 'LAT';
  static const KEY_LON = 'LON';
  static const KEY_TIME = 'TIME';
  static const KEY_ADDRESS = 'ADDRESS';

  static const KEY_LAT_LIST = 'LAT_LIST';
  static const KEY_LON_LIST = 'LON_LIST';
  static const KEY_TIME_LIST = 'TIME_LIST';
  static const KEY_ADDRESS_LIST = 'ADDRESS_LIST';

  factory PreferenceManager() {
    return _instance;
  }

  PreferenceManager._internal();

  Future<void> setPosition(double lat, double lon, bool addToList) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble(KEY_LAT, lat);
    await pref.setDouble(KEY_LON, lon);
    if (addToList) await _addPositionToList(lat, lon);
  }

  Future<double> getLatitude() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(KEY_LAT);
  }

  Future<double> getLongitude() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(KEY_LON);
  }

  Future<void> setTime(String time, bool addToList) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(KEY_TIME, time);
    if (addToList) await _addTimeToList(time);
  }

  Future<String> getTime() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(KEY_TIME);
  }

  Future<void> setAddress(String address, bool addToList) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(KEY_ADDRESS, address);
    if (addToList) await _addAddressToList(address);
  }

  Future<String> getAddress() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(KEY_ADDRESS);
  }

  /// History List instruction

  Future<void> _addPositionToList(double lat, double lon) async {
    final pref = await SharedPreferences.getInstance();
    var latList = await getLatList() ?? List<String>();
    var lonList = await getLonList() ?? List<String>();
    latList.insert(0, lat.toString());
    lonList.insert(0, lon.toString());
    if (latList.length > 10) {
      latList = latList.sublist(0, 10);
    }
    if (lonList.length > 10) {
      lonList = lonList.sublist(0, 10);
    }
    await pref.setStringList(KEY_LAT_LIST, latList);
    await pref.setStringList(KEY_LON_LIST, lonList);
  }

  Future<List<String>> getLatList() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getStringList(KEY_LAT_LIST);
  }

  Future<List<String>> getLonList() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getStringList(KEY_LON_LIST);
  }

  Future<void> _addTimeToList(String time) async {
    final pref = await SharedPreferences.getInstance();
    var timeList = await getTimeList() ?? List<String>();
    timeList.insert(0, time);
    if (timeList.length > 10) {
      timeList = timeList.sublist(0, 10);
    }
    await pref.setStringList(KEY_TIME_LIST, timeList);
  }

  Future<List<String>> getTimeList() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getStringList(KEY_TIME_LIST);
  }

  Future<void> _addAddressToList(String address) async {
    final pref = await SharedPreferences.getInstance();
    var addressList = await getAddressList() ?? List<String>();
    addressList.insert(0, address);
    if (addressList.length > 10) {
      addressList = addressList.sublist(0, 10);
    }
    await pref.setStringList(KEY_ADDRESS_LIST, addressList);
  }

  Future<List<String>> getAddressList() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getStringList(KEY_ADDRESS_LIST);
  }
}
