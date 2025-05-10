## this code modified to the test
# we isolate the serial from the code

import serial
from supabase import create_client, Client
from datetime import datetime

SUPABASE_URL = "https://khexdrhpnxwlpulyaqbk.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
ser = serial.Serial("COM5",115200)
sensor_id = 'Sensor 1'

def read_sensor_data():
    line = ser.readline().decode().strip()
    timestamp = datetime.utcnow().isoformat()
    if line:
        try:
            co2, temp, hum = map(float, line.split(","))
            data = {"CO2": co2, "Temperature": temp, "Humidity": hum, "Timestamp": timestamp, "Sensor id": sensor_id},
            return data
        except ValueError:
            return None
    return None

def send_to_supabase(data):
    response = supabase.table("measurments").insert(data).execute()
    return "Data stored successfully"
