import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = "https://khexdrhpnxwlpulyaqbk.supabase.co"; 
  const supabaseAnonKey =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA"; 
  const testSensorId = 'Sensor 1';
  const testLocation = 'lab 110';
  const testPlant = 'Test Plant';

  setUpAll(() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  });

test('integration:Test model , test insertion in DB', () async {
  // import the model here :
  final modelResponse = await http.post(
    Uri.parse('https://52f6-34-57-103-7.ngrok-free.app/recommend'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'humidity': 45.0,
      'co2': 800.0,
    }),
  );

  expect(modelResponse.statusCode, 200);

  final json = jsonDecode(modelResponse.body);
  final List<String> recommendations = List<String>.from(json['top_3_recommendations']);
  expect(recommendations.length, greaterThan(0));

  //save recommendation in our DB 
  for (final plant in recommendations) {
    await Supabase.instance.client
        .from('Location-plants')
        .insert({
          'sensor_id': 'Sensor 1',
          'Location name': 'lab 110',
          'Plants': plant,
        });
  }

//check the insertion is coreccet ?
  final read = await Supabase.instance.client
      .from('Location-plants')
      .select()
      .eq('sensor_id', 'Sensor 1');

  expect(read.length, greaterThanOrEqualTo(recommendations.length));
});

}
