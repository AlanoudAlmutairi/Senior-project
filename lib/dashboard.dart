import 'package:flutter/material.dart';
import 'package:senior_project_axajah/quick_solutions.dart';
import 'package:senior_project_axajah/recommended_plants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class Dashboard extends StatefulWidget {
  final String selectedSensor;
  const Dashboard(this.selectedSensor, {super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
    String selectedSensor = " " ;
    double co2 =0 ;
    double humidity = 0; 
    double temperature = 0 ;
     var channel ;
    bool _co2WarningShown = false;
     bool _isWarningDialogVisible = false; 
   // RealtimeSubscription? subscription;

      @override
  void initState() {
    super.initState();
    _loadInitialData();
    _subscribeToMeasurements();
    
  }

  // get the last reading from sensor 
  void _loadInitialData() async {
    final data = await Supabase.instance.client
        .from('measurments')
        .select()
        .eq('Sensor id', widget.selectedSensor)
        .order('Timestamp', ascending: false)
        .limit(1);

    if (data.isNotEmpty) {
      final latest = data.first;
      setState(() {
        co2 = (latest['CO2'] ?? 0).toDouble();
        humidity = (latest['Humidity'] ?? 0).toDouble();
        temperature = (latest['Temperature'] ?? 0).toDouble();
      });
    }
  }

  // realTime subscribtion with measurments table to get any changes 
  void _subscribeToMeasurements() {
     channel = Supabase.instance.client.channel('public:measurments')
    .onPostgresChanges(
      callback:  (payload) {
      final newData = payload.newRecord;
      if (newData['Sensor id'] == widget.selectedSensor) {
        setState(() {
          co2 = (newData['CO2'] ?? 0).toDouble();
          humidity = (newData['Humidity'] ?? 0).toDouble();
          temperature = (newData['Temperature'] ?? 0).toDouble();

                 if (co2 < 2000 && _co2WarningShown && _isWarningDialogVisible) {
              _co2WarningShown = false;
              _isWarningDialogVisible = false;
              if (Navigator.canPop(context)) {
                Navigator.pop(context); 
              }
            }
        });
      }  },
    event: PostgresChangeEvent.insert,
    schema:'public',
    table: 'measurments',
      ).subscribe();
     _co2WarningShown = false; 
  }

  @override
  void dispose() {
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel);

    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String locationName ;
    selectedSensor = widget.selectedSensor;


    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F5), // Background color
    appBar: AppBar(
      backgroundColor: Colors.transparent, // No background color
      elevation: 0, // No elevation (no shadow)
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(209, 71, 102, 59),),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
    ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<String>(
        future: getRoomName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          locationName = snapshot.data ?? "Unknown";
          if (co2 >= 2000 && !_co2WarningShown) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                CO2Warning(context);
                _co2WarningShown = true;
                _isWarningDialogVisible = true;
    });
  }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child : Text(
        "Overview",  // Title of the AppBar
        style: TextStyle(
          color: Color.fromARGB(209, 71, 102, 59),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ) , ),
           
  const SizedBox(width: 10),
          Center(
              child: Text(
                  "Room $locationName , $selectedSensor",
                  style: TextStyle(color: Color.fromARGB(209, 71, 102, 59), fontSize: 14),
                )) ,

            const SizedBox(height: 50),

            // Main CO2 Circular Progress
            Center(
              child: Column(
                children: [
                  CustomCircularChart(value: co2, size: 150, division: 10000, title: "CO2 (ppm)"),
                  const SizedBox(height: 30 ),
                    const Text(
                    "CO2 (ppm)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                
                 
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Humidity & Temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DataCard(title: "HUMIDITY (%)", value: humidity),
                DataCard(title: "TEMPERATURE (C)", value: temperature),
              ],
            ),

            const SizedBox(height: 20),

            // Status Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusIndicator(color: Colors.green, text: "Good"),
                StatusIndicator(color: Colors.orange, text: "Fair"),
                StatusIndicator(color: Colors.red, text: "Poor"),
              ],
            ),

            const Spacer(),
          ],
          //down 
        );
  
        },
    ),
    ),
    );
   
  }

Future<String> getRoomName() async {
  
String ? locationName = null  ;

  final name = await Supabase.instance.client.from("Sensors").select('"Sensor id" , "Room name" ').eq("Sensor id", selectedSensor);
//name != null && name.isNotEmpty
  if (name.isNotEmpty ) {
  locationName = name[0]["Room name"].toString();
} else {
  // Handle the case where the location name is not found
  locationName = "Unknown Location"; // or any default value
} 
  return locationName; 
}
 void CO2Warning(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'WARNING!!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6239),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'CO2 level is very high',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.warning_amber_outlined,
                    size: 40,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A6239),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    onPressed: () {
                         Navigator.push(context,MaterialPageRoute(builder: (context) =>recommended_Plants()));
                    },
                    child: const Text(
                      'suggested plants',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD59145),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    onPressed: () {
                       Navigator.push(context,MaterialPageRoute(builder: (context) =>quick_solutions()));
                    },
                    child: const Text(
                      'Quick solution',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 8,
              right: 8, 
              child: GestureDetector(
                onTap: () {
                    _co2WarningShown = false; 
                    _isWarningDialogVisible = false;
                  Navigator.pop(context); 
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
  }
// Custom Circular Chart
class CustomCircularChart extends StatelessWidget {
  final double value;
  final double size;
 final double division ;
 final String title ;

  const CustomCircularChart({super.key, required this.value, required this.size , required this.division , required this.title });

  @override
  Widget build(BuildContext context) {
    Color color = getApproperateColor(); 
 
   return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
             value : value / division ,
              strokeWidth: 15,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
                Text(
            "$value",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    
    );
  
  }

Color getApproperateColor (){
  Color color = Colors.grey; 
     switch(title){
      case "CO2 (ppm)" :
        if(value <= 1000){
          color = Colors.green ;
        }
        else if(value >1000  && value < 2000){
          color = Colors.orange ;
        }
        else if(value >= 2000 ){
          color = Colors.red ;
        }
        break ;
      case "HUMIDITY (%)":  
          if(value <= 30){
          color = Colors.green ;
        }
        else if(value >30  && value <70){
          color = Colors.orange ;
        }
        else if(value >= 70 && value <30 ){
          color = Colors.red ;
        }
        break ;
      case "TEMPERATURE (C)":   
        if(value >=16.0 && value <=26.0 ){
          color = Colors.green ;
        }
        else if(value >27.0  && value <= 30.0){
          color = Colors.orange ;
        }
        else if(value > 30.0  || value <16.0 ){
          color = Colors.red ;
        }
        break ;
    }
    return color ;
}  
}





// Data Card Widget
class DataCard extends StatelessWidget {
  final String title;
  final double value;

  const DataCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: 155,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          CustomCircularChart(value: value, size: 80 , division: 100, title: title, ),
          const SizedBox(height: 25),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Status Indicator Widget
class StatusIndicator extends StatelessWidget {
  final Color color;
  final String text;

  const StatusIndicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
