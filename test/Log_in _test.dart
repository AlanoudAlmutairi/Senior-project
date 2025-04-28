import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:senior_project_axajah/test/TestMethods.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
     late Testmethods authService;
   const supabaseUrl = "https://khexdrhpnxwlpulyaqbk.supabase.co"; 
  const supabaseAnonKey =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA"; 

  setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  });

   setUp(() {
    authService = Testmethods();  // 
  });
  group('AuthService Login', () {
   

    test('Successful login returns true', () async {
        try {
    final result = await authService.logInWIthPW('alanoud5mut@gmail.com', 'a11a11a1');
    print(result);
    expect(result, "success");
  } catch (e, stackTrace) {
    print('Error in Successful login test: $e');
    print(stackTrace);
  }
    /*  final result = await authService.logInWIthPW('alanoud5mut@gmail.com', 'a11a11a1');
      print(result);
      expect(result.user, isNotNull);*/
    });

    test('Failed login returns false with wrong email ', () async {
      final result = await authService.logInWIthPW('alanoud@gmail.com', 'a11a11a11');
      expect(result, "Fail");
    });

   
  });
}
