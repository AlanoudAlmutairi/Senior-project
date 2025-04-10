import 'package:flutter/material.dart';
import 'package:senior_project_axajah/Admin_addSensor.dart';
import 'package:senior_project_axajah/Admin_editSensor.dart';
import 'package:senior_project_axajah/Admin_editUser.dart';
import 'package:senior_project_axajah/Auth_services.dart';
import 'package:senior_project_axajah/Log_in.dart';
import 'package:senior_project_axajah/Temp_profile.dart';
import 'package:senior_project_axajah/dashboard.dart';
import 'package:senior_project_axajah/generate_Report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class AdminProfile extends StatelessWidget {
    late final  User user  ;
  AdminProfile({ required this.user});


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
            Expanded(child: SensorSection(user: user,)), // make scrollable if needed
              SizedBox(height: 20),
            Expanded(child: UsersSection(user: user,)), // make scrollable if needed
          ],
        ),
      ),
    );
  }
}

class SensorSection extends StatefulWidget {
 late final User user;
  SensorSection({required this.user});
 
  @override
  _SensorSectionState createState() => _SensorSectionState();
}

class _SensorSectionState extends State<SensorSection> {
    late String userID = "";
   @override
  void initState() {
    super.initState();
     userID = widget.user.id;
    fetchSensors();
  }
 
  List<Map<String, dynamic>> sensors = [];
  bool loading = true;

  Future<void> fetchSensors() async {
     final response =await Supabase.instance.client.from("Sensors").select('"User_id", "Room name" ,"Sensor id"').eq("User_id",userID );
   
    setState(() {
      sensors = List<Map<String, dynamic>>.from(response as Iterable);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
     return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SENSORS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(209, 71, 102, 59),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: Color.fromARGB(209, 71, 102, 59),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => admin_addSensor(user: widget.user),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: sensors.isEmpty
                        ? Center(
                            child: Text(
                              'No sensors ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: sensors.length,
                            itemBuilder: (context, index) {
                              return SensorTile(sensors[index] , widget.user);
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
final User user ;
  SensorTile(this.sensor ,  this.user);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sensor["Sensor id"] ?? 'No Name'),
      subtitle: Text(sensor["Room name"] ?? 'No Location'),
      trailing: Row(
  mainAxisSize: MainAxisSize.min,
      children: [
            IconButton(
              icon: Icon(Icons.play_arrow,  color: Color.fromARGB(209, 71, 102, 59),),
              onPressed: () {
                 Navigator.push(context,MaterialPageRoute(builder: (context) => Dashboard(sensor["Sensor id"])) );
              },
            ),
            IconButton(
              icon: Icon(Icons.edit,  color: Color.fromARGB(209, 71, 102, 59),),
              onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => admin_editSensor(selectedSensor:sensor["Sensor id"], user: user)) );
                
              },
            ),
          ],
      
    ) ,);
  }

}

class UsersSection extends StatefulWidget {
 late final User user;
 
  UsersSection({required this.user});
 
  @override
  _UsersSectionState createState() => _UsersSectionState();
}

class _UsersSectionState extends State<UsersSection> {
    late String userID = "";
   @override
  void initState() {
    super.initState();
     userID = widget.user.id;
    fetchSensors();
    print("sensors :: $sensors");
  
  }
 
  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> sensors = [];
  bool loading = true;

 
  Future<void> fetchSensors() async {
     final response =await Supabase.instance.client.from("Sensors").select('"User_id", "Room name" ,"Sensor id"').eq("User_id",userID );
   
    setState(() {
      sensors = List<Map<String, dynamic>>.from(response as Iterable);
      loading = false;
      fetchUsers();
    });
  }

  Future<void> fetchUsers() async {
    List<Map<String, dynamic>> TempUsers = [];
    var UserResponse ;
    Set<String> addedUserIDs = {};
 
    for(var sensor in sensors){
      final sensorResponse = await Supabase.instance.client.from("Sensors").select('"User_id" , "Sensor id"').eq("Sensor id", sensor["Sensor id"]);
     
      for(var item in sensorResponse){ 
        if(! addedUserIDs.contains(item["User_id"])){
            UserResponse =await Supabase.instance.client.from("Users").select('"user_id", "Username" ').eq("user_id",item["User_id"] ).single();
        final username = UserResponse["Username"];
        
        if (username != null) {
            TempUsers.add({"user_id":UserResponse["user_id"], "Username": UserResponse["Username"]});
             addedUserIDs.add(item["User_id"]);
             }
        }
      }
    }
    setState(() {
      usersList = TempUsers;
      loading = false;
    });
  }
@override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('USERS', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(209, 71, 102, 59),)),
            if (usersList.isEmpty)
                Center(
                  child: Text(
                    'No users',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
            else
              ...usersList.asMap().entries.map((entry) {
                  int index = entry.key;
                  var user = entry.value;

                  return Column(
                    children: [
                      UserTile(user, widget.user),
                      if (index != usersList.length - 1)
                        Divider(color: Colors.grey[300]),
                    ],
                  );
                }).toList(),
           
         
          ],
          
        ),
        
        
      ),
    ),
    );
  }
}


class UserTile extends StatelessWidget {
  final Map<String, dynamic> userList;
  final User user ;

  UserTile(this.userList , this.user);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(userList["Username"] ?? 'No Name'),
      trailing:  IconButton(
              icon: Icon(Icons.edit,  color: Color.fromARGB(209, 71, 102, 59),),
              onPressed: () {
                 Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) =>admin_EditUser(selectedUserID: userList["user_id"], user: user)),
                        
  );
              },
            ),
    );
  }
}


class Sidebar extends StatefulWidget {
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
      onTap:() {if(title == "Generate Report"){Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GenerateReportScreen(current_user)),
      );

      }} 
    );
  }

  Widget buildSubItem(String title , Widget nextPage) {
    bool isSelected = selectedSubItem == title;

    return Container(
      color: isSelected ? Colors.orange[300] : Colors.green[900],
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        contentPadding: const EdgeInsets.only(left: 40),
        onTap: () {Navigator.push(
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
              accountName: Text(userName?? "NO name available"),
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
              ...sensorsList.map((sensor) => buildSubItem(sensor["Sensor id"],Dashboard(sensor["Sensor id"]))).toList(),
            ],
              

            
            buildMenuTitle('Generate Report', Icons.insert_chart),
            if (userRole == "Admin") ...[
              buildMenuTitle(
                'Manage',
                Icons.settings,
                
                expandable: true,
                onTap: () {
                  setState(() {
                    isManageExpanded = !isManageExpanded;
                  });
                },
              ),
              if (isManageExpanded) ...[
                buildSubItem("Sensors",AdminProfile(user: current_user)),
                buildSubItem("Users", AdminProfile(user: current_user)),
              ],
            ],
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

