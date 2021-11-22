// import 'dart:convert';
//
// import 'package:e_ticketing/constants/route_name.dart';
// import 'package:e_ticketing/locator.dart';
// import 'package:e_ticketing/models/device_data.dart';
// import 'package:e_ticketing/services/api_service.dart';
// import 'package:e_ticketing/services/navigator_service.dart';
// import 'package:e_ticketing/services/storage_service.dart';
// import 'package:e_ticketing/viewmodels/base_model.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils.dart' as escPrinter;
// import 'package:flutter/material.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart' as qrScanner;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ScanQrViewModel extends BaseModel{
//   final NavigationService _navigationService = locator<NavigationService>();
//   final StorageService _storageService = locator<StorageService>();
//   final ApiService _apiService = locator<ApiService>();
//
//
//
//   Device device;
//
//   String message = '';
//   bool connected = false;
//   List<BluetoothInfo> items = [];
//   bool connecting = false;
//
//   String kode;
//   String nama;
//   String dari;
//   String ke;
//   String waktu;
//   String harga;
//   String tanggal;
//
//
//   Widget buildQrView(BuildContext context) {
//     // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
//     var scanArea = (MediaQuery.of(context).size.width < 800 ||
//         MediaQuery.of(context).size.height < 800)
//         ? 200.0
//         : 400.0;
//     // To ensure the Scanner view is properly sizes after rotation
//     // we need to listen for Flutter SizeChanged notification and update controller
//     return qrScanner.QRView(
//       key: qrKey,
//       cameraFacing: qrScanner.CameraFacing.back,
//       onQRViewCreated: _onQRViewCreated,
//       formatsAllowed: [qrScanner.BarcodeFormat.qrcode],
//       overlay: qrScanner.QrScannerOverlayShape(
//         borderColor: Colors.red,
//         borderRadius: 10,
//         borderLength: 30,
//         borderWidth: 10,
//         cutOutSize: scanArea,
//       ),
//     );
//   }
//
//   void inputQrData(qrScanner.Barcode result) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (result != null){
//       String jsonData = await result.code;
//       print(jsonData);
//       await prefs.setString('datadevice',jsonData);
//       // await showdata();
//       if(connected == false){
//         connect();
//         layoutTicket();
//       }else{
//         layoutTicket();
//       }
//       controller.stopCamera();
//       controller.dispose();
//       // _navigationService.pop();
//       // disconnect();
//       _navigationService.replaceTo(DashboardViewRoute);
//     }
//   }
//
//   void _onQRViewCreated(qrScanner.QRViewController controller) {
//     setBusy(true);
//     this.controller = controller;
//
//     controller.scannedDataStream.listen((scanData) {
//       result = scanData;
//       inputQrData(result);
//       controller.dispose();
//     });
//     setBusy(false);
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initClass() {
//     print('init');
//     initPlatformState();
//     showdata();
//   }
//
//   Future<void> initPlatformState() async {
//     setBusy(true);
//     // if (!mounted) return;
//     final bool result = await PrintBluetoothThermal.bluetoothEnabled;
//
//     if (result) {
//       message = "Bluetooth enabled, please search and connect";
//     } else {
//       message = "Bluetooth not enabled";
//     }
//
//     setBusy(false);
//   }
//
//   Future<void> getBluetooth() async {
//     final List<BluetoothInfo> listResult = await PrintBluetoothThermal.pairedBluetooths;
//
//     if (listResult.length == 0) {
//       message = "There are no bluetooth linked, go to settings and link the printer";
//     } else {
//       message = "Touch an item in the list to connect";
//     }
//     setBusy(true);
//     items = listResult;
//     setBusy(false);
//   }
//
//   // Future<void> connect(String mac) async {
//   //   setBusy(true);
//   //     connecting = true;
//   //   final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
//   //   print("state connected $result");
//   //   if (result) connected = true;
//   //     connecting = false;
//   //   setBusy(false);
//   // }
//
//   Future<void> connect() async {
//     setBusy(true);
//     connecting = true;
//     final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: 'DC:0D:51:49:9E:F9');
//     print("state connected $result");
//     if (result) connected = true;
//     connecting = false;
//     setBusy(false);
//   }
//
//   Future<void> disconnect() async {
//     final bool status = await PrintBluetoothThermal.disconnect;
//     setBusy(true);
//     connected = false;
//     setBusy(false);
//     print("status disconnect $status");
//   }
//
//   Future<void> layoutTicket() async {
//     bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
//     if (connectionStatus) {
//       List<int> ticket = await ticketTest();
//       final result = await PrintBluetoothThermal.writeBytes(ticket);
//       print("impresion $result");
//     } else {
//       print("Not Connected");
//     }
//   }
//
//   Future<List<int>> ticketTest() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String dataQR=prefs.getString('datadevice');
//     List<int> bytes = [];
//     // String dataId = '';
//     // String saldo = '';
//
//     // final data = await _apiService.printData(dataId, saldo);
//     // Using default profile
//     final profile = await escPrinter.CapabilityProfile.load();
//     final generator = escPrinter.Generator(escPrinter.PaperSize.mm58, profile);
//     bytes += generator.reset();
//
//     bytes += generator.text('Detail Pembayaran',styles: escPrinter.PosStyles(align: escPrinter.PosAlign.center),linesAfter: 1);
//     bytes += generator.text('Djawatan Angkoetan Motor \n Repoeblik Indonesia \n (DAMRI)',styles: escPrinter.PosStyles(align: escPrinter.PosAlign.center));
//     bytes += generator.hr(ch: '=');
//     bytes += generator.text('Tanggal : $tanggal', styles: escPrinter.PosStyles(align: escPrinter.PosAlign.right), linesAfter: 1);
//     bytes += generator.row([
//       escPrinter.PosColumn(
//         text: 'Kode',
//         width: 3,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: ':',
//         width: 2,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: '$kode',
//         width: 7,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//     ]);
//     bytes += generator.row([
//       escPrinter.PosColumn(
//         text: 'Nama',
//         width: 3,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: ':',
//         width: 2,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: '$nama',
//         width: 7,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//     ]);
//     bytes += generator.row([
//       escPrinter.PosColumn(
//         text: 'Dari',
//         width: 3,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: ':',
//         width: 2,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: '$dari',
//         width: 7,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//     ]);
//     bytes += generator.row([
//       escPrinter.PosColumn(
//         text: 'Ke',
//         width: 3,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: ':',
//         width: 2,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: '$ke',
//         width: 7,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//     ]);
//     bytes += generator.row([
//       escPrinter.PosColumn(
//         text: 'Waktu',
//         width: 3,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: ':',
//         width: 2,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: '$waktu',
//         width: 7,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//     ]);
//     bytes += generator.row([
//       escPrinter.PosColumn(
//         text: 'Harga',
//         width: 3,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: ':',
//         width: 2,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//       escPrinter.PosColumn(
//         text: 'Rp. $harga',
//         width: 7,
//         styles: escPrinter.PosStyles(align: escPrinter.PosAlign.left),
//       ),
//     ]);
//     // bytes += generator.qrcode('${data.dataId}, ${data.saldo}',size: QRSize(10),align: PosAlign.right);
//     bytes += generator.qrcode('$dataQR',size: escPrinter.QRSize(5),align: escPrinter.PosAlign.right);
//     bytes += generator.hr(ch: '=');
//
//     bytes += generator.feed(2);
//     // bytes += generator.cut();
//     return bytes;
//   }
//
//   void showdata()async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String data=prefs.getString('datadevice');
//     var result = jsonDecode(data);
//     var code=result['code'];
//     var name=result['name'];
//     var from= result['from'];
//     var to =result['to'];
//     var time = result['time'];
//     var price=result['price'];
//     var date=result['date'];
//     kode=code;
//     nama=name;
//     dari=from;
//     ke=to;
//     waktu=time;
//     harga=price;
//     tanggal=date;
//   }
//
//   void registerDevice(BuildContext context)async{
//
//     try{
//       if (kode.length > 0 &&
//           nama.length > 0 &&
//           dari.length > 0 &&
//           ke.length > 0 &&
//           waktu.length > 0 &&
//           harga.length > 0 &&
//           tanggal.length > 0) {
//         var code = kode;
//         var name = nama;
//         var from = dari;
//         var to = ke;
//         var time = waktu;
//         var price = harga;
//         var date = tanggal;
//         //guid TEXT PRIMARY KEY, mac TEXT, type TEXT, quantity TEXT, name TEXT, version TEXT, minor TEXT
//         device = Device(
//             code,
//             name,
//             from,
//             to,
//             time,
//             price,
//             date
//         );
//         print(device.toMap().toString());
//         print('$device');
//       }
//     }catch(e){
//       print('Gagal');
//     }
//
//   }
//
// }