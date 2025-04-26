import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:senior_project_axajah/Admin_editSensor.dart';
import 'package:senior_project_axajah/test/temp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


 class MockSupabaseClient extends Mock implements SupabaseClientInterface {}


void main()async{
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
  });


  test('should return success message when update is successful', () async {
      when(() => mockClient.getSensor('S1')).thenAnswer((_) async => [
      {"Sensor id": "S1", "Room name": "Old Room"}
      ]);

    when(() => mockClient.updateLocation(any(), any())).thenAnswer((_) async {});
    when(() => mockClient.updateSensorRoom(any(), any())).thenAnswer((_) async {});

   final method = temp();
  final result = await method.updateValues(
      client: mockClient,
      sensorId: "S1",
      roomName: "New Room",
      roomSize: "Large",
      numPeople: "4",
      light: 100,
    );

    expect(result, equals("Sensor are updated successfully."));
  });

  test('should return error message on exception', () async {
   when(() => mockClient.getSensor(any())).thenThrow(Exception("DB error"));

     final method = temp();
    final result = await method.updateValues(
      client: mockClient,
      sensorId: "X1",
      roomName: "Room X",
      roomSize: "Small",
      numPeople: "1",
      light: 50,
    );

    expect(result, equals("There is an error updating the sensor data."));
  });
}

