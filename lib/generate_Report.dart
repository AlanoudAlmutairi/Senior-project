import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';



class GenerateReportScreen extends StatefulWidget {
    final User user ; 
    GenerateReportScreen(this.user); 

  @override
  GenerateReportScreenState createState() => GenerateReportScreenState();
}

class GenerateReportScreenState extends State<GenerateReportScreen> {
  // Ensure the initial value is from the list
  String selectedSensor =" "; 
  String selectedDuration = "Last 24 hours";
   List<String> sensorsOption =[];
  final List<String> durationOptions = ["Last 24 hours", "Last week", "Last month", "Last year"];
    DateTime nowDate = DateTime.now();
    DateTime startDate = DateTime(0);
    DateTime endDate = DateTime.now();
    List<TableRow> _rows = [];
    List data =[] ;
@override
  void initState() {
    final user = widget.user;
    super.initState();
    getSensorsFromDB(user );
    
  }
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4), // Background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
         leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(209, 71, 102, 59),),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Generate Report',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color.fromARGB(209, 71, 102, 59),
                ),
              ),
            ),
            SizedBox(height: 100),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownField(
                    label: "Choose sensor",
                    value: selectedSensor,
                    onChanged: (newValue) {
                      setState(() {
                        selectedSensor = newValue!;
                      });
                    },
                    items: sensorsOption,
                  ),
                  SizedBox(height: 20),
                  _buildDropdownField(
                    label: "Choose duration",
                    value: selectedDuration,
                    onChanged: (newValue) {
                      setState(() {
                        selectedDuration = newValue!;
                      });
                    },
                    items: durationOptions,
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Center(
              child: ElevatedButton(
                onPressed: () async {
               fetchReportData(selectedDuration, selectedSensor);
                generateReport();
                getRoomName();
                },
                child: Text('Generate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color.fromARGB(209, 71, 102, 59),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
              ),
            ),
             SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(),
                  children: _rows,
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// to build drop down menu for both (sensor id + duration)

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(209, 71, 102, 59),
          ),
        ),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }

 DateTime getDateRange(String selectedDuration){

  switch (selectedDuration) {
    case "Last 24 hours":
      startDate = nowDate.subtract(Duration(hours: 24));
      break;
  
    case "Last week":
      startDate = nowDate.subtract(Duration(days: 6) ) ;
      break; 
      
    case "Last month":
      startDate = DateTime(nowDate.year, nowDate.month - 1, nowDate.day);
      break;
    case "Last year":
      startDate = DateTime(nowDate.year-1, nowDate.month, nowDate.day); 
      break;
  }
  return  startDate;
}

Future<List<String>> fetchRecommendedPlants(String sensorId) async {
  try {
    final response = await Supabase.instance.client
        .from('Location-plants')
        .select('Plants')
        .eq('sensor_id', sensorId);

    if (response == null || response.isEmpty) return [];

    return response.map<String>((plant) => plant['Plants'] as String).toList();
  } catch (e) {
    print("Error fetching plants: $e");
    return [];
  }
}


Future<void> getSensorsFromDB(User user ) async {

  try {
    final userSensors = await Supabase.instance.client
        .from('Sensors').select('"Sensor id" ,"User_id"')
        .eq('User_id', user.id);
            
setState(() {
    if (userSensors != null) {
      for (var sensor in userSensors) {
        sensorsOption.add(sensor['Sensor id'] as String);
        selectedSensor = sensorsOption.first;
      }
    }


});
  
  } catch (error) {
    print('Error fetching sensors: $error');
  }

}

 // get all required data from supabase DB 
  Future<List<dynamic>> fetchReportData(String selectedDuration, String selectedSensor) async {
    final supabase = Supabase.instance.client;
      List<dynamic> readings = [] ;
    
    // Get the date range
    getDateRange(selectedDuration);
    String startTimestamp = startDate.toIso8601String();
    String endTimestamp = endDate.toIso8601String();

    try {
      // Retrieve data from Supabase
       readings  = await supabase
          .from('measurments')
          .select(' "Sensor id", CO2, Humidity, Temperature, Timestamp')
          .eq("Sensor id", selectedSensor)
          .gt("Timestamp", startTimestamp)
          .lte("Timestamp", endTimestamp);

     
    } catch (e) {
      print("Error fetching data: $e");
    }

    return readings ;
  }

//generate the report (style + design + table )
Future<void> generateReport() async {
  final pdf = pw.Document();

 List<dynamic> readings = await fetchReportData(selectedDuration, selectedSensor);
    String roomName = " ";
    final ByteData data = await rootBundle.load('lib/assets/axajah_logo2.png');
    final Uint8List bytes = data.buffer.asUint8List();
  if(! readings.isEmpty){
       roomName =await getRoomName()   ; }
 
  // Add PDF content
  pdf.addPage(
    pw.MultiPage(

       header: (pw.Context context) {
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children:[
                 pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                    pw.Text(
                      "Periodic Report",
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold  ),
                      textAlign: pw.TextAlign.center,
                    ),
                      pw.Text("Sensor : $selectedSensor , Room :$roomName", 
                      style: pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.center,),
          ],
        ),
            pw.Column(
              crossAxisAlignment:pw.CrossAxisAlignment.start ,
              children: [
                pw.Image(
                    pw.MemoryImage(bytes), 
                    width: 200,
                    height: 200,
                  
                  ),
              ],),
        ] );   },

       
      build: (pw.Context context) => [      
        pw.SizedBox(height: 30),

         if (readings.isEmpty)
    pw.Center(
      child: pw.Text(
        'No data available for this sensor during the selected period.\n'
        'OR\nThere are no sensors assigned to your account.',
        style: pw.TextStyle(fontSize: 14, color: PdfColors.red),),
    )
  else
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            // Table Header Row
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.blueGrey100),
              children: [
                tableCell("Timestamp", PdfColors.black, bold: true),
                tableCell("CO2", PdfColors.black, bold: true),
                tableCell("Temperature", PdfColors.black, bold: true),
                tableCell("Humidity", PdfColors.black, bold: true),
              ],
            ),

            // Loop through readings List
            ...readings.map((reading) {
              PdfColor rowColor = PdfColors.black;

             if(reading["CO2"] != null && reading["CO2"] > 2000 ){
              rowColor = PdfColors.red; 
             }
             else if (reading["CO2"] != null && reading["CO2"] > 1000 && reading["CO2"] < 2000) {
                rowColor = PdfColors.orange; 
              } else {
                rowColor = PdfColors.green; 
              }
              String formattedTimestamp = 'N/A';
                if (reading['Timestamp'] != null) {
                 DateTime dateTime = DateTime.parse(reading['Timestamp'].toString());
                  formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
                        }

              return pw.TableRow(
                children: [
                  tableCell(formattedTimestamp, rowColor),
                  tableCell(reading["CO2"].toString(), rowColor),
                  tableCell(reading["Temperature"].toString(), rowColor),
                  tableCell(reading["Humidity"].toString(), rowColor),
                ],
              );
            }),
          ],
        ),
      ],
    ),
  );
   final recommendedPlants = await fetchRecommendedPlants(selectedSensor);

  if (recommendedPlants.isNotEmpty) {
    pdf.addPage(
      pw.MultiPage(
         header: (pw.Context context) {
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children:[
                 pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                    pw.Text(
                      "Recommended Plants",
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold  ),
                      textAlign: pw.TextAlign.center,
                    ),
                      pw.Text("Sensor : $selectedSensor , Room :$roomName", 
                      style: pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.center,),
          ],
        ),
            pw.Column(
              crossAxisAlignment:pw.CrossAxisAlignment.start ,
              children: [
                pw.Image(
                    pw.MemoryImage(bytes), 
                    width: 200,
                    height: 200,
                  
                  ),
              ],),
        ] );   },
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: ['NO', 'Plant Name'],
            data: List.generate(
              recommendedPlants.length,
              (index) => [
                (index + 1).toString(),
                recommendedPlants[index],
              ],
            ),
          headerDecoration: pw.BoxDecoration(
            color: PdfColors.blueGrey100 ,  
          ),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
          cellAlignment: pw.Alignment.center,

          ),
        ],
      ),
    );
  }

  // Save PDF file
  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/periodic_report.pdf");
  await file.writeAsBytes(await pdf.save());

  // Open PDF file
  OpenFile.open(file.path);
}

 /// create table cells with a deffrinte text color
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

//get the room name from DB 
Future<String> getRoomName() async {
  
String ? locationName = null  ;

  final name = await Supabase.instance.client.from("Sensors").select('"Sensor id" , "Room name" ').eq("Sensor id", selectedSensor);

  if (name != null && name.isNotEmpty ) {
  locationName = name[0]["Room name"].toString();
} else {
  locationName = "Unknown Location"; 
} 
  return locationName; 
}



}








