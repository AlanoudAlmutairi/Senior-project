
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_project_axajah/test/TestMethods.dart';
import 'package:path/path.dart' as p;
void main() {
TestWidgetsFlutterBinding.ensureInitialized();

  test('generateMockReport creates a non-empty PDF file', () async {
    final tempWidget = Testmethods();
    
    final dir = await Directory.systemTemp.createTemp();
    final outPutPath = p.join(dir.path, 'test_report.pdf');
    print(outPutPath);

     final ByteData imageData = await rootBundle.load('lib/assets/axajah_logo2.png');
    expect(imageData.lengthInBytes, greaterThan(0));
    
    var report = await tempWidget.generateMockReport(outPutPath);
    final file = File(outPutPath);
    expect(await file.exists(), isTrue);
    expect(report, "Report created successfully");

    final content = await file.readAsBytes();
    expect(content.length, greaterThan(0));
    await file.delete();
  });

  test('generateMockReport throws an exception when file creation fails', () async {
  final tempWidget = Testmethods();
  
  final invalidPath = '/invalid_path/test_report.pdf';
  print(invalidPath);
  expect(
  () async => await tempWidget.generateMockReport(invalidPath),
  throwsA(
    predicate((e) => e is Exception && e.toString().contains('Failed to generate report'))
  ),
);
});

  }





