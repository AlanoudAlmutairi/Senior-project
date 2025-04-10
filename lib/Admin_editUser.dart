import 'package:flutter/material.dart';
import 'package:senior_project_axajah/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:project/Profile_admin.dart';
import 'Admin_profile.dart';

class admin_editUser extends StatefulWidget {
    
    late final String selectedUserID  ;
    late final User admin ;
    admin_editUser( this.selectedUserID , this.admin );
  @override
  _admin_editUserState createState() => _admin_editUserState();
}

class _admin_editUserState extends State<admin_editUser> {
     List<Map<String, dynamic>> userSensors = [];
       List<Map<String, dynamic>> adminSensors = [];
     late String userName = " " ;
     
@override
void initState() {
  super.initState();
   getUserName();
  fetchUserSensors();
  fetchAdminSensors();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF7F5),  //0xFFFDF7F5
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
       ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                     //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => admin_profile()),  );
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

           
  
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ASSIGNED SENSORS",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ,  color: Color.fromARGB(209, 71, 102, 59),),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle,  color: Color.fromARGB(209, 71, 102, 59),),
                 onPressed: () { 
                  showSensorPopup(context );
                  },
                  
                           ),
              ],
            ), 
          ...userSensors.asMap().entries.map((entry) {
            int index = entry.key;
          //  Map sensor = entry.value;
            return _buildSensorCard(userSensors[index]["Sensor id"], userSensors[index]["Room name"]);
          }).toList(),

          
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, String subtitle) {
      late var  sensor ;
    ListView.builder(
  itemCount: userSensors.length, // كم عنصر عندي
  itemBuilder: (context, index) {
      sensor= userSensors[index]; // أجيب العنصر الحالي
    return ListTile(
      title: Text(sensor['Sensor id']), // أعرض الاسم
      subtitle: Text(sensor['Room name']), // أعرض الغرفة
    );
  },
  );
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
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(title)),  );
              },
            ),
           IconButton(
        icon: Icon(Icons.delete, color: Colors.grey),
        onPressed: () async {
            await Supabase.instance.client.from("Sensors").delete().eq("Sensor id", title).eq("User_id", widget.selectedUserID);
          
            await fetchUserSensors();
            setState(() {}); 
                },
),

          ],
        ),
      ),
    );
  }
Future<void> fetchUserSensors() async {

  final data = await Supabase.instance.client
      .from('Sensors')
      .select('"User_id", "Room name" ,"Sensor id"')
      .eq('User_id',widget.selectedUserID );

  setState(() {
    userSensors = data;
  });
}
Future<void> fetchAdminSensors() async {

  final data = await Supabase.instance.client
      .from('Sensors')
      .select('"User_id", "Room name" ,"Sensor id"')
      .eq('User_id',widget.admin.id);

  setState(() {
    adminSensors = data;
  });
}

Future<void> getUserName()async{
  final response = await Supabase.instance.client.from("Users").select('"Username" , "user_id"').eq("user_id" , widget.selectedUserID);
  userName = response[0]["Username"];
}

void showSensorPopup(BuildContext context) async{
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                    Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const Text(
                  'Choose sensor',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E582D),
                  ),
                ),
                const SizedBox(height: 24),

                ...adminSensors.map((sensor) {
                return Column(
                  children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,   
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      onPressed: () async {
                        await Supabase.instance.client.from("Sensors").insert({
                          "Sensor id": sensor["Sensor id"],
                          "Room name": sensor["Room name"],
                          "User_id": widget.selectedUserID,
                        });
                        await fetchUserSensors();
                        setState(() {});
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sensor['Sensor id']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E582D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sensor['Room name']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2E582D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),

              ],
            ),
          ),
        ),
      );
    },
  );
}


}