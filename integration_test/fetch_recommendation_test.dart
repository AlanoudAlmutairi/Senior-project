import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:senior_project_axajah/test/TestMethods.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const upabaseUrl = "https://khexdrhpnxwlpulyaqbk.supabase.co"; 
  const supabaseAnonKey =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA"; 
  const testSensorId = 'Sensor 1';
  const testLocation = 'lab 110';

  setUpAll(() async {
    await Supabase.initialize(
      url: upabaseUrl,
      anonKey: supabaseAnonKey,
    );
  });
  test('Integration: fetchDataAndRecommend and storeToDB', () async {
    Testmethods testmethods = Testmethods();
  
   List<String> plants =  await testmethods.fetchDataAndRecommend(testSensorId, testLocation);

    expect(plants, isNotEmpty);

   String storeMSG = await testmethods.storeToDB(testSensorId, testLocation, plants);

   expect(storeMSG, "Data Stored Successfully"); 
  });
}


