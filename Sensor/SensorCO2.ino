/*
By: Nathan Seidle SparkFun Electronics  
Library: http://librarymanager/All#SparkFun_SCD30  
*/

///// GOOD  CODE 

#include <Wire.h>
#include "SparkFun_SCD30_Arduino_Library.h" 

SCD30 airSensor;

void setup() {
    Serial.begin(115200);  // Start Serial Monitor
    Wire.begin();  // Start I2C communication
    if (airSensor.begin() == false) {
        Serial.println("SCD30 not detected. Check wiring.");
        while (1);
    }  }

void loop()  
{
  if (airSensor.dataAvailable())
  {
    Serial.print(airSensor.getCO2());
    Serial.print(",");

    //Serial.println(" temp(C):");
    Serial.print(airSensor.getTemperature(), 1);
    Serial.print(",");

    //Serial.println(" humidity(%):");
    Serial.println(airSensor.getHumidity(), 1);
    Serial.println();
  }
  else
    Serial.println("No data");
    delay(10000);
    // delay(60000);
}