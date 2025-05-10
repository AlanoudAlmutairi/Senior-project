import 'package:flutter/material.dart';
import 'package:senior_project_axajah/Admin_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class admin_editSensor extends StatefulWidget  {
  
    late final String selectedSensor  ;
    final User user ;
    admin_editSensor({required this.selectedSensor , required this.user});

    @override
  AdminEditSensorState createState() => AdminEditSensorState();
}


class AdminEditSensorState extends State<admin_editSensor> {

//var to store data that retreived fro db 
   late String roomName ;
   late String roomSize  ;
    String sensorID ="";
   late int numOfPeople  ;
   int light = 0;

//Text controller to get user input
TextEditingController sensorIDController = TextEditingController();  
TextEditingController roomNameController = TextEditingController();   
TextEditingController roomSizeController = TextEditingController(); 
TextEditingController numOfPeopleController = TextEditingController(); 

  @override
  Widget build(BuildContext context) {
         
    return Scaffold(
       backgroundColor: const Color(0xFFFDF7F4),//FDF7F4
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //iconTheme: IconThemeData(color: Colors.black),
      ),
      body:  FutureBuilder<List>(
      future: getCompletInfo(), // 
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

        final roomData = snapshot.data![0]; 

        //update the values 
        sensorIDController.text =widget.selectedSensor  ; 
        roomName = roomData["Location name"].toString();
        roomNameController.text = roomName;
        roomSize = roomData["Location size"].toString();
        roomSizeController.text = roomSize;
        light = int.parse(roomData["Location light"].toString());
        numOfPeople = int.parse(roomData["Number of people"].toString());
        numOfPeopleController.text = numOfPeople.toString();
      
      
     return SafeArea(
         child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
 Center(
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: Color(0xFFFDF7F4),
      border: Border.all(
        color: Color.fromARGB(209, 71, 102, 59), // Border color
      width: 1, // Border width
    ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
     widget.selectedSensor,
      style: TextStyle(color: Color.fromARGB(209, 71, 102, 59), fontSize: 16 ,fontWeight:FontWeight.bold),
    ),
    
  ),
),
SizedBox(height: 20),

          
            SizedBox(height: 20),
            _buildTextField('Sensor ID (cannot be modified.)',  widget.selectedSensor ,sensorIDController, true),
            _buildTextField( 'Room Name',  roomName ,roomNameController, false),
            _buildTextField( 'Room Size', roomSize, roomSizeController, false),
            _buildTextField( 'Average number of people',  numOfPeople.toString(),numOfPeopleController , false ),
            SizedBox(height:20),
            Text('Room Light(%) (cannot be modified.)', style: TextStyle(color: Color.fromARGB(209, 71, 102, 59) ,fontWeight: FontWeight.bold)),
            Row(
              key: ValueKey<int>(light),
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRadioOption(0 ),
                _buildRadioOption(50 ),
                _buildRadioOption(100 ),
              ],
            ),
            ///
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    deletSensor();
                    showSuccessDialog(context , "Sensor deleted" ,Icons.check_circle , Colors.green , widget.user);
                  },
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton(
                  onPressed: ()async {
                 String message =await updateSensor();
                 if(message.contains("successfully")){
                      showSuccessDialog(context , message ,Icons.check_circle , Colors.green , widget.user);
                 }else 
                 showSuccessDialog(context , message , Icons.warning_amber_rounded, Colors.red, widget.user);
                  
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
      }
      ),
    );
  }

  Widget _buildTextField( String label,  String initialValue , TextEditingController controller , bool read) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Color.fromARGB(209, 71, 102, 59),fontWeight: FontWeight.bold)),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          //controller: TextEditingController(text: initialValue),
        controller: controller,
        readOnly: read,
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildRadioOption(int label ) {
    return Row(
      children: [
        Radio(
          value: label,
          groupValue:light ,
          onChanged: (value) {
            setState(() {
              if(value != null){
               light = value; }
    
});
          },
        ),
        
        Text(label.toString()),
      ],
    );
  }

 Future<String> getRoomName() async {
  String room ="" ;
final  response = await Supabase.instance.client.from("Sensors")
.select('"Sensor id" , "Room name" ').eq("Sensor id", widget.selectedSensor);
  if (response != null ) {
  room = response[0]["Room name"].toString();}

 return room ;
}

 Future<List> getCompletInfo()async {
  String roomN = await getRoomName() ;
  final response = await Supabase.instance.client.from('Location')
  .select('"Location name","Location size" , "Number of people" , "Location light"')
  .eq('Location name', roomN);


return response as List ;
}


Future <String> updateSensor()async {
  String message ; 
try{
  final room = await Supabase.instance.client.from("Sensors").select('"Sensor id" ,"Room name" ').eq("Sensor id", widget.selectedSensor);

 await Supabase.instance.client.from("Location").update({
  "Location name" : roomNameController.text,
  "Location size" : roomSizeController.text,
  "Number of people" : numOfPeopleController.text,
  "Location light" : light,
  }).eq("Location name", room[0]["Room name"]);

await Supabase.instance.client.from("Sensors").update({"Room name" : roomNameController.text}).eq("Sensor id", widget.selectedSensor);
return message = "Sensor are updated successfully. ";

}catch(e){
  return message = "There is an error updating the sensor data." ;
  
}
}
Future<void> deletSensor() async{
   // 1. get selscted sensor information
  final room = await Supabase.instance.client
      .from("Sensors").select('"Sensor id", "Room name"')
      .eq("Sensor id", widget.selectedSensor);

  // get the room 
  final String roomName = room[0]["Room name"];

  // 2.delete selected sensor 
  await Supabase.instance.client
      .from("Sensors").delete()
      .eq("Sensor id", widget.selectedSensor);

  // 3. check there is any other sensor in the same room (location)
  final remainingSensors = await Supabase.instance.client
      .from("Sensors").select()
      .eq("Room name", roomName);

  // 4.if there is no other sensors in the same room , delete the room 
  if (remainingSensors.isEmpty) {
    await Supabase.instance.client
        .from("Location") .delete()
        .eq("Location name", roomName);
  }



}


void showSuccessDialog(BuildContext context , String msg , IconData iconName , Color iconColor , User user) { {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconName, size: 50, color: iconColor ),
              SizedBox(height: 10),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                //Navigator.push(context,MaterialPageRoute(builder: (context) => AdminProfile(user: user)) );
               Navigator.pop(context);
               Navigator.pop(context);
                 
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
}