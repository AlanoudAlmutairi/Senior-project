import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  

  //log in 
  Future<AuthResponse> logInWIthPW(String email , String password)async{
    final SupabaseClient _supabase = Supabase .instance.client;
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password);
  }
  // sign in 

  Future <AuthResponse> signUpWithPW(String email , String password )async{
    final SupabaseClient _supabase = Supabase .instance.client;
    return await _supabase.auth.signUp(
     
      email: email,
      password: password
      );
      
  }

  // sign out 
  Future<void> signOut()async{
    final SupabaseClient _supabase = Supabase .instance.client;
    await _supabase.auth.signOut() ;
  }

}