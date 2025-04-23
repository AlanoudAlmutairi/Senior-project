import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*
 url: "https://khexdrhpnxwlpulyaqbk.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA",
  );
*/

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const testSensorId = 'test-sensor-123';
  const testLocationName = 'test-room';

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
url: "https://khexdrhpnxwlpulyaqbk.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA",
    );

    // إضافة بيانات اختبارية في جدول measurments
    await Supabase.instance.client.from('measurments').insert({
      'Sensor id': testSensorId,
      'CO2': 2300,
      'Temperature' : 29,
      'Humidity': 55,
      'Timestamp': DateTime.now().toIso8601String(),
    });
  });

  test('Fetches data, gets recommendations and inserts into Location-plants', () async {
    // استدعاء دالة التوصية
    final response = await http.post(
      Uri.parse('https://52f6-34-57-103-7.ngrok-free.app/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'humidity': 55, 'co2': 2300}),
    );

    expect(response.statusCode, 200);
    final List<dynamic> recommended = jsonDecode(response.body)['top_3_recommendations'];

    // إدخال النتائج في Supabase
    for (final plant in recommended) {
      await Supabase.instance.client.from('Location-plants').insert({
        'sensor_id': testSensorId,
        'location name': testLocationName,
        'plants': plant,
      });
      
    }

    // التحقق من أن البيانات تم تخزينها
    final result = await Supabase.instance.client
        .from('Location-plants')
        .select()
        .eq('sensor_id', testSensorId);

    expect(result.length, recommended.length);
    for (final plant in recommended) {
      expect(
        result.any((r) => r['plant_name'] == plant),
        true,
      );
    }
  });

  tearDownAll(() async {
print("🧹 Cleaning up test data...");

  final measurmentRes = await Supabase.instance.client
      .from('measurments')
      .delete()
      .eq('"Sensor id"', testSensorId)
     ;

    if (measurmentRes.error != null) {
    print("❌ Error while deleting from measurments:");
    print("↳ ${measurmentRes.error!.message}");
  } else {
    print("✅ Deleted from measurments");
  }

  final locationRes = await Supabase.instance.client
      .from('Location-plants')
      .delete()
      .eq('"Sensor_id"', testSensorId)
      ;
  if (locationRes.error != null) {
    print("❌ Error while deleting from Location-plants:");
    print("↳ ${locationRes.error!.message}");
  } else {
    print("✅ Deleted from Location-plants");
  }
}) ;

}


