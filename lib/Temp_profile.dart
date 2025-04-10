import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class admin_EditUser extends StatefulWidget  {
  
    late final String selectedUserID  ;
    final User user ;
    admin_EditUser({required this.selectedUserID, required this.user});

    @override
  _AdminEditUserState createState() => _AdminEditUserState();
}


class _AdminEditUserState extends State<admin_EditUser> {
  String userName = " " ;
  List<Map<String, dynamic>> usersSensors = [];
  List<Map<String, dynamic>> adminSensors = [];
  bool loading = true;
          @override
    void initState() {
      super.initState();
      fetchUsersSensors();
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFFDF7F5),  //0xFFFDF7F5
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
       ),
      body:  FutureBuilder<String>(
      future:getUserName(), // 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); 
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error:  ${snapshot.error}")); 
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("NO data available"));     
        }

        final userName = snapshot.data!;       
      return 
       Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                  //   Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => admin_profile()), );
                   Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 10),
            
Center(
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: Color(0xFFFDF7F4),
      border: Border.all(
        color: Color.fromARGB(209, 71, 102, 59), // Border color
      width: 1,
    ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
     userName,
      style: TextStyle(color: Color.fromARGB(209, 71, 102, 59), fontSize: 16 ,fontWeight:FontWeight.bold),
    ),
  ),
),
SizedBox(height: 70),
SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ASSIGNED SENSORS"),
          IconButton(onPressed: () {}, icon: Icon(Icons.add_circle)),
        ],
      ),
      SizedBox(height: 10),
      usersSensors.isEmpty
          ? Center(child: Text("No sensors"))
          : ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: usersSensors.length,
              itemBuilder: (context, index) {
                return _buildSensorCard(usersSensors[index]["Sensor id"], usersSensors[index]["Room name"]);
              },
              separatorBuilder: (context, index) =>
                  Divider(height: 10, color: Colors.grey[300]),
            ),
    ],
  ),
),
           SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF51633E),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
      }
      )
    );
  
  }

  Widget _buildSensorCard(String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow,  color: Color.fromARGB(209, 71, 102, 59),),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

Future<String> getUserName()async{
  String userName ;
  final response = await Supabase.instance.client.from("Users").select('"Username" , "user_id"').eq("user_id" , widget.selectedUserID);
  userName = response[0]["Username"];
  return userName;
}

  Future<void> fetchUsersSensors() async {
   final response =await Supabase.instance.client.from("Sensors").select('"User_id", "Room name" ,"Sensor id"').eq("User_id",widget.selectedUserID );
   
    setState(() {
      usersSensors = List<Map<String, dynamic>>.from(response);
      loading = false;
    });

  }

    Future<void> fetchAdminSensors() async {
   final response =await Supabase.instance.client.from("Sensors").select('"User_id", "Room name" ,"Sensor id"').eq("User_id",widget.user.id );
   
    setState(() {
      adminSensors = List<Map<String, dynamic>>.from(response);
      loading = false;
    });

  }


}
