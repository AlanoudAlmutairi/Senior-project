
import 'package:flutter/material.dart';
import 'package:senior_project_axajah/Admin_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class admin_addSensor extends StatefulWidget  {
  final User user ;
    admin_addSensor({ required this.user});
    @override
  _AdminAddSensorState createState() => _AdminAddSensorState();
}


class _AdminAddSensorState extends State<admin_addSensor> {


  TextEditingController sensorIDController = TextEditingController();
  TextEditingController roomSizeController = TextEditingController();
  TextEditingController roomNameController = TextEditingController();
  TextEditingController numOfPeopleController = TextEditingController();

  String sensorID =" " ;
  int slelctedLight = 0  ;

  String ? _roomNameError ;
  String ? _roomSizeError ;
  String ? _peopleError ;
  String ? _sensorIDError ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4),//FDF7F4
       resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
         leading: IconButton(
          icon: Icon(Icons.arrow_back,   color: Color.fromARGB(209, 71, 102, 59),),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
     
      ),
      body:  SafeArea(
         child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'ADD NEW SENSOR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(209, 71, 102, 59),
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildTextField( 'Sensor ID (It cannot be modified later.) ',  'ex: 10', sensorIDController , TextInputType.text, _sensorIDError),
            _buildTextField('Room Name', 'ex: manager room',roomNameController, TextInputType.text , _roomNameError),
            _buildTextField( 'Room Size',  'ex: 3 * 4 m',roomSizeController ,TextInputType.text,_roomSizeError),
            _buildTextField('Average number of people', 'ex: 3 people',numOfPeopleController , TextInputType.text, _peopleError),
           
            SizedBox(height: 30),
            Text('Room Light (%) (It cannot be modified later.)', style: TextStyle(fontWeight: FontWeight.bold ,  color: Color.fromARGB(209, 71, 102, 59), )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRadioOption(0),
                _buildRadioOption(50),
                _buildRadioOption(100),
              ],
            ),
            SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  _validate();
                
                  final existingSensor = await Supabase.instance.client.from('Sensors')
                  .select('"Sensor id"').eq("Sensor id", sensorIDController.text).maybeSingle();
                   

                  if (existingSensor != null) {
                    showSuccessDialog(context ,"Sensor ID is already exist " , Icons.warning_amber_rounded, Colors.red, widget.user); 
                   
                    }
                  else if (_peopleError==null  && _roomNameError == null && _roomSizeError==null && _sensorIDError==null) {
                  StoreLocation() ;
                  StoreSensor() ;
                   showSuccessDialog(context ,"The sensor has been successfully Added!", Icons.check_circle , Colors.green , widget.user); 
                 
                  }  
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
              ),
            ),
             SizedBox(height: 20),
          ],
        ),
      ),
    ),
        ),
      );
  }

   Widget _buildTextField( String label  ,String hintText , TextEditingController controller,
  TextInputType keyboardType  ,String ? error 
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(209, 71, 102, 59),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        //keyboardType: keyboardType,
        maxLines: 1,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
     
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          errorText: error ,
        ),
          
      ),
      const SizedBox(height: 20),
    ],
  );
   
  }

  Widget _buildRadioOption(int label, {bool selected = false}) {
     return Row(
      children: [
        Radio(
          value: label,
          groupValue: slelctedLight ,
          onChanged: (value) {
              setState(() {
              slelctedLight = value! ;
             
            });
            
          },
        ),
        Text(label.toString()),
      ],
    );
}

 Future<void> StoreLocation()async {
    String room_size = roomSizeController.text ;
    int number_of_people = int.parse(numOfPeopleController.text);
    String room_name = roomNameController.text ;
  

    await Supabase.instance.client.from('Location').insert({
      'Location name': room_name,
      "Location light" : slelctedLight ,
      "Location size" : room_size ,
      'Number of people' : number_of_people, 

    }) ;
}

Future<void> StoreSensor()async {
    String sensor_id = sensorIDController.text ; 
    String roomName = roomNameController.text;
  
  await Supabase.instance.client.from('Sensors').insert({
    "Room name" : roomName ,
    "Sensor id" : sensor_id ,
   
    "User_id" : widget.user.id,
  });
  }


 void showSuccessDialog(BuildContext context , String msg , IconData iconName , Color iconColor , User user) {
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
              Icon(iconName, size: 50, color: iconColor),
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
                  Navigator.push(context,MaterialPageRoute(builder: (context) =>AdminProfile(user:user ,)));
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

void _validate() {
setState(() {
// Check if the fields are empty and set error messages accordingly
 _roomNameError = roomNameController.text.isEmpty ? "Room name is required" : null;
 _roomSizeError = roomSizeController.text.isEmpty ? "Room size is required" : null;
 _peopleError = numOfPeopleController.text.isEmpty ? "Number of people is required" : null ;
 _sensorIDError = sensorIDController.text.isEmpty ? "Sensor ID is required" : null ;
});

}


 


}
