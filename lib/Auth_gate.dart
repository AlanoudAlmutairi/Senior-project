import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senior_project_axajah/Admin_addSensor.dart';
import 'package:senior_project_axajah/Log_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Widget build(BuildContext context){
    return StreamBuilder(
      //listen to auth state change
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      //build 
      builder: (context , snapShot){
        if(snapShot.connectionState == ConnectionState.waiting){
          return const Scaffold( 
            body: Center(child: CircularProgressIndicator(),),);
        }

      //check if there is a valid session 
      final session = snapShot.hasData?snapShot.data!.session :  null ;
      if(session != null){
          return Login();
      }
      else {
      return Login();}

      }
      );
  }
}