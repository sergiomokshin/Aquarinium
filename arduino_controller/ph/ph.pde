
/*
This software was made to demonstrate how to quickly get your Atlas Scientific product running on the Arduino platform.
An Arduino MEGA 2560 board was used to test this code.
This code was written in the Arudino 1.0 IDE
Modify the code to fit your system.
**Type in a command in the serial monitor and the Atlas Scientific product will respond.**
**The data from the Atlas Scientific product will come out on the serial monitor.**
Code efficacy was NOT considered, this is a demo only.
The TX3 line goes to the RX pin of your product.
The RX3 line goes to the TX pin of your product.
Make sure you also connect to power and GND pins to power and a common ground.
Open TOOLS > serial monitor, set the serial monitor to the correct serial port and set the baud rate to 38400.
Remember, select carriage return from the drop down menu next to the baud rate selection; not "both NL & CR".
*/



String inputstring = "C";                                                       //a string to hold incoming data from the PC
String sensorstring = "";                                                      //a string to hold the data from the Atlas Scientific product
boolean input_stringcomplete = true;                                          //have we received all the data from the PC
boolean sensor_stringcomplete = false;                                         //have we received all the data from the Atlas Scientific product


void setup(){                                                                //set up the hardware
     Serial.begin(38400);                                                      //set baud rate for the hardware serial port_0 to 38400
     Serial3.begin(38400);                                                     //set baud rate for software serial port_3 to 38400
     //inputstring.reserve(5);                                                   //set aside some bytes for receiving data from the PC
     //sensorstring.reserve(30);                                                 //set aside some bytes for receiving data from Atlas Scientific product
}
 
 
 
void serialEvent() {                 //if the hardware serial port_0 receives a char
  
     char inchar = (char)Serial.read();                               //get the char we just received
     delay(50);
     inputstring += inchar;                                           //add it to the inputString
     if(inchar == '|') {input_stringcomplete = true;}                //if the incoming character is a <CR>, set the flag
}  


void serialEvent3(){                                                         //if the hardware serial port_3 receives a char 
      char inchar = (char)Serial3.read();                              //get the char we just received
      delay(50);
      sensorstring += inchar;                                          //add it to the inputString
      if(inchar == '\r') {sensor_stringcomplete = true;}               //if the incoming character is a <CR>, set the flag 
}



 void loop(){                                                                   //here we go....

     Serial.println(inputstring);                   
               
     serialEvent();
     serialEvent3();
     
  if (input_stringcomplete){                                                   //if a string from the PC has been recived in its entierty 
      Serial3.print(inputstring);                                              //send that string to the Atlas Scientific product
      delay(50);
      inputstring = "";                                                        //clear the string:
      input_stringcomplete = false;                                            //reset the flage used to tell if we have recived a completed string from the PC
      }

 if (sensor_stringcomplete){                                                   //if a string from the Atlas Scientific product has been recived in its entierty 
      Serial.println(sensorstring);                                            //send that string to to the PC's serial monitor
            delay(50);
      sensorstring = "";                                                       //clear the string:
      sensor_stringcomplete = false;                                           //reset the flage used to tell if we have recived a completed string from the Atlas Scientific product
      }
      
      delay(50);
 }


