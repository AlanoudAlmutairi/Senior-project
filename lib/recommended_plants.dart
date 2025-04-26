import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecommendedPlants extends StatefulWidget {
  final String sensorId;
  final String locationName;

  const RecommendedPlants({
    required this.sensorId,
    required this.locationName,
    super.key,
  });

  @override
  _RecommendedPlantsState createState() => _RecommendedPlantsState();
}

class _RecommendedPlantsState extends State<RecommendedPlants> {
  List<String> plants = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDataAndRecommend();
  }

  Future<void> fetchDataAndRecommend() async {
    try {
      print("📡 Sensor ID received: ${widget.sensorId}");
      // 1. Get latest CO2 and Humidity readings
      final data = await Supabase.instance.client
          .from('measurments')
          .select()
          .ilike('Sensor id', widget.sensorId)
          .order('Timestamp', ascending: false)
          .limit(1);
print("📡 Sensor ID received: ${widget.sensorId}");
      if (data.isEmpty) {
        setState(() {
          error = "No sensor data found.";
          loading = false;
        });
        return;
      }

      final latest = data.first;
      final double humidity = (latest['Humidity'] ?? 0).toDouble();
      final double co2 = (latest['CO2'] ?? 0).toDouble();

    print("✅ CO2: $co2, Humidity: $humidity");

      // 2. Send to ML model API
      final response = await http.post(
        Uri.parse('https://d9fc-35-196-48-172.ngrok-free.app/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'humidity': humidity, 'co2': co2}),
      );

    print("🧠 Model Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<String> recommended = List<String>.from(data['top_3_recommendations']);

        setState(() {
          plants = recommended;
          loading = false;
        });

        // 3. Save to Supabase
        for (final plant in recommended) {
          print("📥 Saving to Supabase: location=${widget.locationName}, plant=$plant");
          await Supabase.instance.client.from('Location-plants').insert({
            'sensor_id': widget.sensorId,
            'Location name': widget.locationName,
            'Plants': plant,
          });
        }
      } else {
        setState(() {
          error = "Model error: ${response.statusCode}";
          loading = false;
        });
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        error = "Error occurred: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(209, 71, 102, 59)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Based on your environment and CO₂ level,\nthese are recommended plants:",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recommended Plants",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(209, 71, 102, 59),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...plants.map((plant) => _buildPlantCard(plant)).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildPlantCard(String plantName) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        plantName,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}