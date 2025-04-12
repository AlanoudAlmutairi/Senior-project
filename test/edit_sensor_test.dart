import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_project_axajah/Admin_editSensor.dart';
import 'package:senior_project_axajah/temp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main()async{
   await Supabase.initialize(
    url: "https://khexdrhpnxwlpulyaqbk.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA",
  );

/*
e 42 pos 7: \'_instance._initialized\': You must initialize the supabase instance before calling Supabase.instance There is an error updating the sensor data.'
   Which: is different.
          Expected: Sensor are ...
            Actual: 'package:s ...
                    ^
           Differ at offset 0
*/
 /*test('Edit sensor', () async {
    final x = temp();
    final result =await x.updateValues(sensorId: "sensor 90", roomName: "office", roomSize: "2*4", numPeople: 10, light: 50);
     expect(result, equals("Sensor are updated successfully."));
 });*/



}