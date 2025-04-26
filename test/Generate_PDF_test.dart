
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_project_axajah/test/temp.dart';
import 'package:path/path.dart' as p;
void main() {
TestWidgetsFlutterBinding.ensureInitialized();

  test('generateMockReport creates a non-empty PDF file', () async {
    final tempWidget = temp();
    
    final dir = await Directory.systemTemp.createTemp();
    final outPutPath = p.join(dir.path, 'test_report.pdf');

    final ByteData imageData = await rootBundle.load('lib/assets/axajah_logo.png');
    expect(imageData.lengthInBytes, greaterThan(0));
    
    await tempWidget.generateMockReport(outPutPath);
    final file = File(outPutPath);
    expect(await file.exists(), isTrue);

    final content = await file.readAsBytes();
    expect(content.length, greaterThan(0));
    await file.delete();
  });
  }





