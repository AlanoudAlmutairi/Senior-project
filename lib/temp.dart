


import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://khexdrhpnxwlpulyaqbk.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA",
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: temp(),
    );
  }
}


class temp extends StatelessWidget {

///// FOR Generate_PDF_test  
Future<void> generateMockReport(String outPutPath) async {
  final pdf = pw.Document();

  // test data 
  final readings = [
    {
      "CO2": 1500,
      "Temperature": 25,
      "Humidity": 50,
      "Timestamp": DateTime.now().toIso8601String(),
    },
    {
      "CO2": 800,
      "Temperature": 23,
      "Humidity": 40,
      "Timestamp": DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
    }
  ];

  final roomName = "Test Room";

  final ByteData data = await rootBundle.load('lib/assets/axajah_logo.png');
  final Uint8List bytes = data.buffer.asUint8List();

  pdf.addPage(
    pw.MultiPage(
      header: (pw.Context context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Periodic Report",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text("Sensor: Sensor 1, Room: $roomName",
                  style: pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.Image(pw.MemoryImage(bytes), width: 100, height: 100),
        ],
      ),
      build: (pw.Context context) => [
        pw.SizedBox(height: 30),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.blueGrey100),
              children: [
                tableCell("Timestamp", PdfColors.black, bold: true),
                tableCell("CO2", PdfColors.black, bold: true),
                tableCell("Temperature", PdfColors.black, bold: true),
                tableCell("Humidity", PdfColors.black, bold: true),
              ],
            ),
            ...readings.map<pw.TableRow>((reading) {
                  PdfColor rowColor = PdfColors.black;
                  final co2Value = reading["CO2"] as num? ;
                 if(co2Value != null && co2Value > 2000 ){
                  rowColor = PdfColors.red; 
                 }
                  else if (reading["CO2"] != null && co2Value! > 1000 && co2Value < 2000) {
                    rowColor = PdfColors.orange; 
                  } else {
                    rowColor = PdfColors.green; 
                  }

              final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(DateTime.parse(reading["Timestamp"].toString()));

              return pw.TableRow(children: [
                tableCell(formattedTime, rowColor),
                tableCell(reading["CO2"].toString(), rowColor),
                tableCell(reading["Temperature"].toString(), rowColor),
                tableCell(reading["Humidity"].toString(), rowColor),
              ]);
            }),
          ],
        ),
      ],
    ),
  );

  final dir = await Directory.systemTemp.createTemp(); 
  final file = File(outPutPath);
  await file.writeAsBytes(await pdf.save());

}
pw.Widget tableCell(String text, PdfColor color, {bool bold = false}) {


  return pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}


////// FOR edit_sensor_test
  Future<String> updateValues({
    required String sensorId,
    required String roomName,
    required String roomSize,
    required int numPeople,
    required int light,
  }) async {
    String message =" ";
    try {
      final room = await Supabase.instance.client
          .from("Sensors")
          .select('Sensor id, Room name')
          .eq("Sensor id", sensorId);

      await Supabase.instance.client.from("Location").update({
        "Location name": roomName,
        "Location size": roomSize,
        "Number of people": numPeople,
        "Location light": light,
      }).eq("Location name", room[0]["Room name"]);

      await Supabase.instance.client.from("Sensors").update({
        "Room name": roomName,
      }).eq("Sensor id", sensorId);

      return message = "Sensor are updated successfully.";
    } catch (e) {
      return message = "$e There is an error updating the sensor data.";
    }
  }
  
 


 
 
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

   // String x = updateValues(sensorId: "sensor 90", roomName: "office", roomSize: "2*4", numPeople: 10, light: 50);
    throw UnimplementedError();
  }
}


