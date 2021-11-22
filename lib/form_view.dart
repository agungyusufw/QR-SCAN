import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_scan/user_location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart' as loc;


class FormView extends StatefulWidget {
  // const FormView({Key? key}) : super(key: key);

  @override
  _FormViewState createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  TextEditingController nama = TextEditingController();
  TextEditingController isi = TextEditingController();
  TextEditingController longitude = TextEditingController();
  TextEditingController latitude = TextEditingController();

  void openLocationSetting() async {
    await LocationService().checkService();
  }

  Future<void> getLocation() async {
    setState(() async {
      try {
        final userLocation = await GeolocatorService().getCurrentLocation();
        latitude.text = userLocation.latitude.toString();
        longitude.text = userLocation.longitude.toString();
        print('Latitude ${latitude.text}');
        print('Longitude ${longitude.text}');
      } catch (e) {
        print('No Long Lat');
      }
    });

  }

  void dataQR()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data=prefs.getString('datadevice');
    var result = jsonDecode(data);
    nama.text = result['nama'];
    isi.text = result['isi'];
    longitude.text;
    latitude.text;
  }

  @override
  void initState() {
    super.initState();
    openLocationSetting();
    getLocation();
    dataQR();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              TextFormField(
                controller: nama,
                decoration: InputDecoration(
                  hintText: 'Nama'
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: isi,
                decoration: InputDecoration(
                    hintText: 'Isi'
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: longitude,
                decoration: InputDecoration(
                    hintText: 'Longitude'
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: latitude,
                decoration: InputDecoration(
                    hintText: 'Latitude'
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: (){
                    Text('Sudah Submit');
                  },
                  child: Text('Submit')
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class GeolocatorService {
  // final Geolocator _geolocator = Geolocator();
  Future<UserLocation> getCurrentLocation() async {
    try {
      var addressLine = '';
      final geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.bestForNavigation,
      );
      final Coordinates coordinates =
      Coordinates(position.latitude, position.longitude);
      print(coordinates);
      final addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);

      if (position.isMocked) {
        addressLine = addresses.first.addressLine + ' #FakeLocation';
      } else {
        addressLine = addresses.first.addressLine;
      }

      UserLocation userLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        addressLine: addressLine,
      );

      return userLocation;
    } catch (e) {
      print('[getCurrentLocation] Error Ocurred ${e.toString()}');
      return null;
    }
  }
}

class LocationService {
  bool _serviceEnabled;
  final loc.Location location = new loc.Location();

  Future<void> checkService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }
}


