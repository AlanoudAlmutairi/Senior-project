import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import  'package:senior_project_axajah/generate_Report.dart';
import 'package:senior_project_axajah/temp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
   final NowDate = DateTime.now();
   final fixedNow = DateTime(NowDate.year , NowDate.month , NowDate.day , NowDate.hour , NowDate.minute , NowDate.second);
   
    group('getDateRange', () {
    setUp(() {
      final b = GenerateReportScreenState ();
      b.nowDate = fixedNow ;
    }); });

  test('should return last 24 hours', () {
      final x = GenerateReportScreenState();
      final result = x.getDateRange("Last 24 hours");
      //result with out mili second
      final result2 =DateTime(result.year,result.month , result.day , result.hour , result.minute , result.second); 
      expect(result2, equals(fixedNow.subtract(Duration(hours: 24))));
    });

    test('should return last week', () {
      final x = GenerateReportScreenState();
      final result = x.getDateRange("Last week");
       //result with out mili second
      final result2 =DateTime(result.year,result.month , result.day , result.hour , result.minute , result.second);
      expect(result2, equals(fixedNow.subtract(Duration(days: 6))));
    });
  testWidgets('should return last month', (tester) async {
    final x = GenerateReportScreenState();
      final result = x.getDateRange("Last month");
       
      final expexted =  DateTime(fixedNow.year, fixedNow.month - 1, fixedNow.day);
       expect(result, equals(expexted));
  });

      test('should return last year', () {
        final x = GenerateReportScreenState();
        final result = x.getDateRange("Last year");
        final expected = DateTime(fixedNow.year - 1, fixedNow.month, fixedNow.day);
        expect(result, equals(expected));
    });
}



