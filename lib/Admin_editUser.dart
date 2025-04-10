import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class admin_editUser extends StatefulWidget {
  final String userId;

  admin_editUser({required this.userId});

  @override
  admin_editUserState createState() =>admin_editUserState();
}

class  admin_editUserState extends State<admin_editUser> {
  List<dynamic> assignedSensors = [];
  TextEditingController sensorIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAssignedSensors();
  }

  Future<void> fetchAssignedSensors() async {
    final response = await Supabase.instance.client
        .from('sensors')
        .select()
        .contains('user_id', [widget.userId]);

    if (response.isNotEmpty) {
      setState(() {
        print("Response $response");
        assignedSensors = response;
      });
    }
  }

  Future<void> addSensorToUser(String sensorId) async {
    final sensorData = await Supabase.instance.client
        .from('sensors')
        .select('user_id')
        .eq('sensor id', sensorId);

    if (sensorData.isEmpty) return;

    List users = sensorData[0]['user_id'];
    if (users.contains(widget.userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User already has access to this sensor")),
      );
      return;
    }

    users.add(widget.userId);
    await Supabase.instance.client
        .from('sensors')
        .update({'user_id': users})
        .eq('sensor id', sensorId);

    fetchAssignedSensors();
    sensorIdController.clear();
  }

  Future<void> removeSensorFromUser(String sensorId) async {
    final sensorData = await Supabase.instance.client
        .from('sensors')
        .select('user_id')
        .eq('sensor id', sensorId);

    if (sensorData.isEmpty) return;

    List users = sensorData[0]['user_id'];
    users.remove(widget.userId);

    await Supabase.instance.client
        .from('sensors')
        .update({'user_id': users})
        .eq('sensor id', sensorId);

    fetchAssignedSensors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Edit User", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Assigned Sensors:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...assignedSensors.map((sensor) {
                return Card(
                  child: ListTile(
                    title: Text(sensor['sensor id'] ?? 'Unknown ID'),
                    subtitle: Text(sensor['Room name'] ?? 'Unknown Room'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => removeSensorFromUser(sensor['sensor id']),
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 20),
              TextField(
                controller: sensorIdController,
                decoration: InputDecoration(labelText: "Add Sensor ID"),
              ),
              ElevatedButton(
                onPressed: () => addSensorToUser(sensorIdController.text),
                child: Text("Add Sensor"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}