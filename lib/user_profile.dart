import 'package:flutter/material.dart';
import 'package:senior_project_axajah/Admin_addSensor.dart';
import 'package:senior_project_axajah/Auth_services.dart';
import 'package:senior_project_axajah/Log_in.dart';
import 'package:senior_project_axajah/dashboard.dart';
import 'package:senior_project_axajah/generate_Report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class UserProfile extends StatefulWidget {

     late User  current_user;
  UserProfile({required this.current_user});
  @override
  _UserProfileState createState() => _UserProfileState();
}
class _UserProfileState  extends State<UserProfile> {
  late User user ;
  late String username ; 
  @override
  void initState() {
    super.initState();
    user = widget.current_user;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Sidebar(current_user: user, ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(child: SensorSection(currentUser: user,)),
          ],
        ),
      ),
    );
  }
}


class SensorSection extends StatefulWidget {
  late final User currentUser;
  SensorSection({required this.currentUser});
 
  @override
  _SensorSectionState createState() => _SensorSectionState();
}

class _SensorSectionState extends State<SensorSection> {
  late String userID = widget.currentUser.id;
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> sensors = [];
  bool loading = true;

  @override
  void initState(){
    super.initState();
     fetchSensors(); 
    
  }

  Future<void> fetchSensors() async {
   final response =await Supabase.instance.client.from("Sensors").select('"User_id", "Room name" ,"Sensor id"').eq("User_id",userID );
   
    setState(() {
      sensors = List<Map<String, dynamic>>.from(response);
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
     final  User user = widget.currentUser ;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SENSORS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(209, 71, 102, 59),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                     child: sensors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No sensors',
                                style: TextStyle(
                                  fontSize: 16,
                                  //color: Colors.grey[600],
                                  color: Colors.black ,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Please take your sensor information from your admin , then add the sensor from '),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => admin_addSensor(user: user),
                                    ),
                                  );
                                },
                                child: Text(
                                  'HERE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(209, 71, 102, 59),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            
                        : ListView.separated(
                            itemCount: sensors.length,
                            itemBuilder: (context, index) {
                              return SensorTile(sensors[index]);
                            },
                            separatorBuilder: (context, index) =>
                                Divider(height: 10, color: Colors.grey[300]),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SensorTile extends StatelessWidget {
  final Map<String, dynamic> sensor;

  SensorTile(this.sensor);

  @override
  
  
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sensor['Sensor id'] ?? 'No Name'),
      subtitle: Text(sensor['Room name'] ?? 'No Location'),
      trailing: IconButton(
        icon: Icon(
          Icons.play_arrow,
          color: Color.fromARGB(209, 71, 102, 59),
        ),
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context) => Dashboard(sensor["Sensor id"])) );
        },
      ),
    );
  }  }


class Sidebar extends StatefulWidget {
  //final String userRole; // "USER" or "ADMIN"
  //final String userName;
  late User  current_user;

   Sidebar({required this.current_user});
  

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isDashboardExpanded = true;
  bool isManageExpanded = true;

  String selectedSubItem = "";


   late final User current_user ;
  String? userName;
  String? userEmail;
  String? userRole ;
   final authService = AuthServices();
   List<Map<String, dynamic>> sensorsList = [];

  @override
  void initState() {
    super.initState();
    current_user = widget.current_user;
    String id = current_user.id ;
    fetchUserData();
    fetchSensors();
  }

  Future<void> fetchUserData() async {
    
    if (current_user != null) {
      final response = await Supabase.instance.client
          .from('Users')
          .select()
          .eq('"user_id" , "User permission" , "Email"', current_user.id )
          .single();

      setState(() {
        userName = response['Username'] ?? 'User';
        userEmail = response['Email'] ?? current_user.email;
        userRole = response["User permission"] ?? null ;
      });
    }
  }
   Future<void> fetchSensors() async {
   final response =await Supabase.instance.client.from("Sensors").select('"User_id", "Room name" ,"Sensor id"').eq("User_id",current_user.id );
   
    setState(() {
      sensorsList = List<Map<String, dynamic>>.from(response);
    });

  }

  Widget buildMenuTitle(String title, IconData icon ,{bool expandable = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: expandable ? const Icon(Icons.expand_more, color: Colors.white) : null,
      onTap:() {
        if(title == "Generate Report"){
         Navigator .push(
        context,
        MaterialPageRoute(builder: (context) => GenerateReportScreen(current_user)),
      );} }
    );
  }

  Widget buildSubItem(String title , Widget nextPage) {
    bool isSelected = selectedSubItem == title;

    return Container(
      color: isSelected ? Colors.orange[300] : Colors.green[900],
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        contentPadding: const EdgeInsets.only(left: 40),
        onTap: () {
            Navigator .push(
              context,
              MaterialPageRoute(builder: (context) => nextPage),
            );
          setState(() {
            selectedSubItem = title;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF3C5C3B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF3C5C3B)),
              accountName: Text(userName?? "NO user_name available"),
              accountEmail: Text(userRole?? "User"),
              currentAccountPicture: const CircleAvatar(
               backgroundImage: AssetImage('lib/assets/UserLogo.jpg'), 
              ),
            ),
            buildMenuTitle(
              'Dashboard',
              Icons.dashboard,
              expandable: true,
              onTap: () {
                setState(() {
                  isDashboardExpanded = !isDashboardExpanded;
                });
              },
            ),
          
            if (isDashboardExpanded) ...[
              ...sensorsList.map((sensor) => buildSubItem(sensor["Sensor id"] , Dashboard(sensor["Sensor id"]))).toList(),
            ],
              

            
            buildMenuTitle('Generate Report', Icons.insert_chart  ),
          
            const Divider(color: Colors.white60),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white),
              title: const Text("Help", style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout Account", style: TextStyle(color: Colors.red)),
              onTap: () {
                 authService.signOut();
                Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),);

              },
            ),
          ],
        ),
      ),
    );
  }
}
