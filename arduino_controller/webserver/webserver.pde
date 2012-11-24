                                                               /*
Monitor de Aquário

por Sérgio de Miranda e Castro Mokshin
 
Protocolo para acionar saída via WEB
ligar saida 3 IS31
desligar saida 3 IS30
 
 ILR1
 ILR0
 
LCD RS pin to digital pin 12
LCD Enable pin to digital pin 11
LCD D4 pin to digital pin 5
LCD D5 pin to digital pin 4
LCD D6 pin to digital pin 3
LCD D7 pin to digital pin 2
 
 
byte rowPins[ROWS] = {32, 22, 24, 28}; //connect to the row pinouts of the keypad
byte colPins[COLS] = {30, 34, 26}; //connect to the column pinouts of the keypad


Temperatura
http://bildr.org/2011/07/ds18b20-arduino/
Pin 6
 
 
 */
#define BUFSIZ 100
#include <SPI.h>
#include <Ethernet.h>
#include <stdio.h>
#include <stdlib.h> 
#include <LiquidCrystal.h>
#include <Keypad.h>
#include <Wire.h>  
#include <avr/wdt.h>
#include <OneWire.h>

#define PIN_BLUE 7
#define PIN_RED 8
#define PIN_GREEN 9

#define PIN_SAIDA_TERMO 31
#define PIN_SAIDA_BOMBA 33
#define PIN_SAIDA_LUZ 35
#define PIN_SAIDA_AUX1 37

#define PIN_SAIDA_BUZZ 41


#define PIN_ENTRADA_NIVEL_B 39
#define PIN_ENTRADA_NIVEL_A 41

#define PIN_ENTRADA_TEMP 0


#define HORAS 2
#define MINUTOS 1
#define SEGUNDOS 0   
#define DIASEMANA 3
#define DIAMES 4  
#define MES 5 
#define ANO 6 


int DS18S20_Pin = 6; //DS18S20 Signal pin on digital 2

//Temperature chip i/o
OneWire ds(DS18S20_Pin); // on digital pin 2


const byte ROWS = 4; 
const byte COLS = 3; 
char keys[ROWS][COLS] = {
  {'1','2','3'},
  {'4','5','6'},
  {'7','8','9'},
  {'#','0','*'}
};
byte rowPins[ROWS] = {32, 22, 24, 28}; 
byte colPins[COLS] = {30, 34, 26}; 

Keypad keypad = Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS );

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1, 70 };
char entradas [] = {'E','0','0','0','0','0','0','0','0'};

Server server(80);
char clientline[BUFSIZ];
char comando[BUFSIZ];
char comando_teclado[BUFSIZ];
int index;
int tamanhocomando;

boolean inicioComando1;
boolean inicioComando2;
boolean inicioFuncaoTeclado;
boolean inicioComandoTeclado;
boolean fimComando;
boolean recebendoComandoWeb;
int indiceentrada;

int HoraConfirmada;
int QtdHoraConfirmada;

boolean modoAutomatico;

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

//PH
int indexPH;
char clientPH[3];
String inputstring = "C";                                                       
String sensorstring = "";                                                      
boolean input_stringcomplete = true;                                          
boolean sensor_stringcomplete = false;                                         


void setup()
{

  //ds1307setup();
  
  HoraConfirmada = 0;
  QtdHoraConfirmada = 0;
  
  wdt_enable(WDTO_8S);

  Serial.begin(38400);
  Wire.begin(); 
   
 Serial3.begin(38400);                                                     
       
  pinMode(PIN_ENTRADA_NIVEL_B, INPUT);
  pinMode(PIN_ENTRADA_NIVEL_A, INPUT);
  
  pinMode(PIN_SAIDA_BOMBA, OUTPUT);     
  pinMode(PIN_SAIDA_TERMO, OUTPUT);     
  pinMode(PIN_SAIDA_AUX1, OUTPUT);     
  pinMode(PIN_SAIDA_LUZ, OUTPUT);     
  pinMode(PIN_SAIDA_BUZZ, OUTPUT);     
  
  digitalWrite(PIN_SAIDA_BOMBA, LOW);
  digitalWrite(PIN_SAIDA_TERMO, LOW);
  digitalWrite(PIN_SAIDA_AUX1, LOW);
  digitalWrite(PIN_SAIDA_LUZ, LOW);
  digitalWrite(PIN_SAIDA_BUZZ, LOW);
 
 
  Ethernet.begin(mac, ip);
  server.begin();
  inicioComando1 = false;
  inicioFuncaoTeclado = false;
  inicioComandoTeclado = false;
  inicioComando2 = false;
  fimComando = false;
  recebendoComandoWeb = false;
  indiceentrada = 0;
  
  modoAutomatico = true;
  
  
  lcd.begin(20, 4);
  lcd.print("PH           A 26.32");
  lcd.setCursor(0, 1);
  lcd.print("Aquadroid           ");
  BuzzerConfirma();
  indexPH = 0;
   
}

void loop()
{  
  wdt_reset(); 
  PrintData();
  AguardaComandosTeclado();
//AguardaComandosWEB();   
  ModoAutomatico(); 
  LeituraTemperatura();
  LeituraPH();    
}


void LeituraPH() {    
  
     //ConfiguraPH();
     //Serial3.print("C\r");
     serialEvent3();
     
 if (sensor_stringcomplete){
      Serial.println(clientPH);
      delay(50);
      
      lcd.setCursor(3, 0);
      lcd.print(clientPH);
      
      lcd.setCursor(7, 0);
      lcd.print("    ");
      
      indexPH = 0;
      sensorstring = "";                                                       
      sensor_stringcomplete = false;                                           
      Serial.println("PH LIDO");
      }
      
}  

 void ConfiguraPH() {                
   
   char inchar = (char)Serial.read();
     
   if(inchar == 'R') {
      Serial3.print("R\r");
   }
   
  if(inchar == 'C') {
      Serial3.print("C\r");
   }
   
   if(inchar == 'E') {
      Serial3.print("E\r");
   }
   
    if(inchar == 'I') {
      Serial3.print("I\r");
   }
   
    if(inchar == 'S') {
      Serial3.print("S\r");
   }
   
    if(inchar == 'F') {
      Serial3.print("F\r");
   }
   
    if(inchar == 'T') {
      Serial3.print("T\r");
   }
   
   
   
  }  


 void serialEvent3(){
   
      char c = (char)Serial3.read();  
      
      if(c == '\r'){
        sensor_stringcomplete = true;        
      } 
      else      
      {
        if(validateNumber(c)){
          clientPH[indexPH] = c;
          indexPH++;          
        }
      }              
 }
bool validateNumber(char caracter) {  
  return (caracter == '0' || caracter == '1' || caracter == '2' || caracter == '3' || caracter == '4' || caracter == '5' || caracter == '6' || caracter == '7' || caracter == '8' || caracter == '9' || caracter == '.'); 
}
 

void LeituraTemperatura()
{
  
  float temperature = getTemp();
  Serial.println(temperature);
  lcd.setCursor(15, 0);     
  lcd.print(temperature);
}


float getTemp(){
 //returns the temperature from one DS18S20 in DEG Celsius

 byte data[12];
 byte addr[8];

 if ( !ds.search(addr)) {
   //no more sensors on chain, reset search
   ds.reset_search();
   return -1000;
 }

 if ( OneWire::crc8( addr, 7) != addr[7]) {
   Serial.println("CRC is not valid!");
   return -1000;
 }

 if ( addr[0] != 0x10 && addr[0] != 0x28) {
   Serial.print("Device is not recognized");
   return -1000;
 }

 ds.reset();
 ds.select(addr);
 ds.write(0x44,1); // start conversion, with parasite power on at the end

 byte present = ds.reset();
 ds.select(addr);  
 ds.write(0xBE); // Read Scratchpad

 
 for (int i = 0; i < 9; i++) { // we need 9 bytes
  data[i] = ds.read();
 }
 
 ds.reset_search();
 
 byte MSB = data[1];
 byte LSB = data[0];

 float tempRead = ((MSB << 8) | LSB); //using two's compliment
 float TemperatureSum = tempRead / 16;
 
 return TemperatureSum;
 
}

int ConfirmaTrocaHora(int hora)
{ 
  
  if(HoraConfirmada == hora)
  {
    QtdHoraConfirmada = 0;
    return hora;
  }
  else
  {
    QtdHoraConfirmada++;
  }
    
  if(QtdHoraConfirmada>=4)
  {
    HoraConfirmada = hora;
  }
  
  return HoraConfirmada;
}

void ModoAutomatico(){

  lcd.setCursor(13, 0);     
  if (modoAutomatico == true){
    
    digitalWrite(PIN_SAIDA_BOMBA, LOW);
    digitalWrite(PIN_SAIDA_TERMO, LOW);
      
    lcd.print("A");  
    int rtc[7];
    ds1307get(rtc,true);
    
    int hora = ConfirmaTrocaHora(rtc[HORAS]);
    
    if (hora < 6){
      digitalWrite(PIN_SAIDA_AUX1, LOW);
      digitalWrite(PIN_SAIDA_LUZ, LOW);
      analogWrite(PIN_RED, 0);
      analogWrite(PIN_GREEN, 0);
      analogWrite(PIN_BLUE, 0);                 
    } 
    else if (hora >= 7 && hora <= 12){      
      digitalWrite(PIN_SAIDA_LUZ, LOW);
      analogWrite(PIN_RED, 255);
      analogWrite(PIN_GREEN, 255);
      analogWrite(PIN_BLUE, 255);                 
    } 
    else if (hora >= 13 && hora <= 19){      
      digitalWrite(PIN_SAIDA_LUZ, HIGH);
      analogWrite(PIN_RED, 0);
      analogWrite(PIN_GREEN, 0);
      analogWrite(PIN_BLUE, 0);                 
    } 
    else if (hora >= 20 && hora < 21){      
      digitalWrite(PIN_SAIDA_LUZ, LOW);
      analogWrite(PIN_RED, 255);
      analogWrite(PIN_GREEN, 255);
      analogWrite(PIN_BLUE, 255);                 
    } 
    else if (hora >= 21 && hora < 22){      
      digitalWrite(PIN_SAIDA_LUZ, LOW);
      analogWrite(PIN_RED, 0);
      analogWrite(PIN_GREEN, 0);
      analogWrite(PIN_BLUE, 255);                 
    } 
    else if (hora >= 22 && hora < 23){      
      digitalWrite(PIN_SAIDA_LUZ, LOW);
      analogWrite(PIN_RED, 0);
      analogWrite(PIN_GREEN, 0);
      analogWrite(PIN_BLUE, 50);                 
    } 
    else if (hora >= 23){      
      digitalWrite(PIN_SAIDA_LUZ, LOW);
      analogWrite(PIN_RED, 0);
      analogWrite(PIN_GREEN, 0);
      analogWrite(PIN_BLUE, 0);                 
    }         
  } 
  else{
     lcd.print("M"); 
  }        
}


void BuzzerConfirma()
{
  buzz(PIN_SAIDA_BUZZ, 3000, 50);        
  buzz(PIN_SAIDA_BUZZ, 2500, 30);        
  buzz(PIN_SAIDA_BUZZ, 3500, 250);        
}

void BuzzerClica()
{
  buzz(PIN_SAIDA_BUZZ, 3500, 100);    
}

void BuzzerCancela()
{
  buzz(PIN_SAIDA_BUZZ, 3500, 500);        
}

void AguardaComandosTeclado()
{   
  char key = keypad.getKey();
  if (key != NO_KEY){    
    BuzzerClica();
    lcd.setCursor(0, 1);
    lcd.print("Selecione uma funcao"); 
    lcd.setCursor(0, 2); 
    
    Serial.print("KEY: ");
    Serial.println(key);
   
   if( inicioComandoTeclado == true )
   {          
     Serial.println("Executado comando");
     
     if(key == '#')
     {
        BuzzerCancela();
        ComandoCancelado();
        Serial.println("Comando Cancelado");
     }
     else if (key == '*')
     {
         index++;
         clientline[index] = 'F';
        // clientline[index] = 0; 
         Serial.println(clientline);
         DisparaComando();
         ComandoExecutado();
         Serial.println("Comando Executado");
         Serial.println(clientline);
         BuzzerConfirma();
     }
     else
     {    
       index++;
       clientline[index] = key;   
       Serial.print("Armazenando buffer: ");
       Serial.println(key);
       Serial.println(clientline);
       
     }
         
   }   
   else 
   {             
      inicioComandoTeclado = true;   
      index = 0;
      tamanhocomando = 0;
       memset( &clientline, 0, BUFSIZ ); //clear inString memory 
       
       Serial.println("Executado menu");
        inicioFuncaoTeclado = true;
        switch (key) {
         case '1':
               clientline[index] = 'I';
               index++;
               clientline[index] = 'L';
               index++;
               clientline[index] = 'R';      
               lcd.print("Luz Vermelha 0..250 ");        
               break;
         case '2':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'L';
              index++;
              clientline[index] = 'G';
              lcd.print("Luz Verde 0..250    ");
              break;
         case '3':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'L';
              index++;
              clientline[index] = 'B';                           
              lcd.print("Luz Azul 0..250     ");
              break;
          case '4':
              clientline[index] = 'I';
              index++;
              clientline[index] = 'S';
              index++;
              clientline[index] = '4';                           
              lcd.print("Bomba 1:ON = 0:OFF  ");
              break;
          case '5':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'S';
              index++;
              clientline[index] = '3';                           
              lcd.print("Termo 1:ON = 0:OFF  ");      
              break;
          case '6':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'S';
              index++;
              clientline[index] = '2'; 
              lcd.print("LUZ 1:ON = 0:OFF ");
              break;
          case '7':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'S';
              index++;
              clientline[index] = '1';   
              lcd.print("Saida 1 1:ON = 0:OFF ");
              break;
          case '8':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'M';         
              index++;
              clientline[index] = 'A';   
              lcd.print("Auto 1:ON = 0:OFF ");
              Serial3.print("C\r");
              break;
          case '9':
              lcd.print("Não programado ");              
               break;    
          case '#':
              ComandoCancelado();
              break;  
          case '*':             
              ComandoCancelado();
              break;   
         }      
   }  
  }  
}

void ComandoCancelado()
{
    lcd.setCursor(0, 1); 
    lcd.print("Comando cancelado   ");

    lcd.setCursor(0, 2);     
    lcd.print("                    ");
    
    lcd.setCursor(0, 2);     
    lcd.print("                    ");
    inicioFuncaoTeclado = false;
    inicioComandoTeclado = false;
  
}


void ComandoExecutado()
{
    lcd.setCursor(0, 1); 
    lcd.print("Comando executado   ");

    lcd.setCursor(0, 2);     
    lcd.print("                    ");
    
    lcd.setCursor(0, 2);     
    lcd.print("                    ");
    inicioFuncaoTeclado = false;
    inicioComandoTeclado = false; 
  
}
void AguardaComandosWEB()
{   
  recebendoComandoWeb = false;   
  Client client = server.available();
  
  if (client) {         
    while (client.connected()) {
      if (client.available()) {        
        if (recebendoComandoWeb == false) 
        {
          index = 0;
          tamanhocomando = 0;
          boolean currentLineIsBlank = true;    
          memset( &clientline, 0, BUFSIZ ); //clear inString memory      
          recebendoComandoWeb = true;
        }
        
        char c = client.read();        
        if (c != '\n' && c != '\r') {
          clientline[index] = c;
          index++;
           if (index >= BUFSIZ) 
              index = BUFSIZ -1;       
          continue;
        }             
          //Serial.print(index);
          //Serial.print("-");
          //Serial.print(clientline);
          
          clientline[index] = 0;               
          DisparaComando();               
          Header(client); 
          break;
      }
    }
    delay(1);
    client.stop();
  }
}

void DisparaComando()
{  
    boolean iniciocomando = false;       
    for (int i = 0; i<index ; i++)
    {    
         if(clientline[i] == 'I')
         {
            iniciocomando = true;
         }
         else if(clientline[i] == 'F')
         {
            break;               
         }               
         else if(iniciocomando)
         {
            comando[tamanhocomando] = clientline[i];
            tamanhocomando++;                                                           
         }                           
    }                

    comando[index] = 0;      
    
    lcd.setCursor(0, 3);    
    lcd.print(comando);


    Serial.print("Tipo Comando: ");
    Serial.println(comando[0]);

    if (comando[0] == 'L')
    {
       DisparaLuz();      
    }       
    else if (comando[0] == 'S')
    {
       DisparaSaida();      
    }
    else if (comando[0] == 'M')
    {
       DisparaModo();      
    }
}
void DisparaModo(){

  Serial.print("Aqui");
  Serial.print(comando);
  
  char modo = comando[2];
  Serial.print(modo);
    
  if (modo == '0'){
    modoAutomatico = false;
  }    
  else{
    modoAutomatico = true;
  }
  
}

void DisparaLuz()
{
  int nivel = 0;
  
  char nivelaux[3];
  nivelaux[0] = comando[2];
  nivelaux[1] = comando[3];
  nivelaux[2] = comando[4];
  nivel = atoi(nivelaux);    
   
  char pin =  comando[1];   
  switch (pin) {
   case 'R':
  	 analogWrite(PIN_RED, nivel);
  	 break;
   case 'G':
  	 analogWrite(PIN_GREEN, nivel);
  	 break;
   case 'B':
  	 analogWrite(PIN_BLUE, nivel);
  	 break;    
   }
}


void DisparaSaida()
{
    int nivel = 0;
    if(comando[2] == '0') 
    {
         nivel = 0;   
    }     
    else  
    {
         nivel = 1;   
    }     
    char pin =  comando[1];
       
  switch (pin) {
    
     case '4':
	 digitalWrite(PIN_SAIDA_BOMBA, nivel);
	 break;
     case '3':
	 digitalWrite(PIN_SAIDA_TERMO, nivel);
	 break;
     case '2':
	 digitalWrite(PIN_SAIDA_LUZ, nivel);
	 break;
     case '1':
	 digitalWrite(PIN_SAIDA_AUX1, nivel);
	 break;
     }  
 }

void LerTemperatura()
{
  
int pinoSensor = 10; 
int valorLido = 0; 
float temperatura = 0;                        //wait one second before sending new data
valorLido = analogRead(pinoSensor); 
temperatura = (valorLido * 0.00488); 
temperatura = temperatura * 100; 
Serial.print("Temperatura actual: "); 
Serial.println(temperatura); 

}


void Header(Client client)
{
  client.println("HTTP/1.1 200 OK");
  client.println("Content-Type: text/html");
  client.println();
  client.println("<html><head><title>Webserver</title>");
  client.println("</head> ");

  client.println("<style>");
  client.println(".QuadroSite{width: 960px;margin: 0 auto;}");
  client.println(".Banner{width: 970px;height: 120px;background-color:#3399CC;padding-top: 1px;}");
  client.println(".Principal{padding-top: 30px;width: 970px;background-color:#EEEEEE;height: 500px;margin: 0 auto;overflow:auto;}");
  client.println(".MainMonitor{width:100%;height:100%;position:relative;}");
  client.println(".BlocoMonitorEntrada{padding-left: 20px;margin-left: 20px;background-color: #FFFFFF;width:430px;height:430px;float:left;border:thin solid #CCCCCC;}");
  client.println(".BlocoItensMonitor{padding-top: 10px;}");
  client.println(".TextoSaida{float:left;margin-right:15px;}");        
  client.println(".IcoSaida{width:15px;height:15px;marging-left:50px;margin-right:10px;float:left}");
  client.println("h1{font-size:20px;margin-left: 10px;font-name: Calibri;color:white;padding-top: 5px;}");
  client.println("span{font-size:13px;font-name: Calibri;color:black;}");
  client.println("</style>");

  client.println("<body><div class='QuadroSite'>");
  client.println("<div class='Banner'><h1>WebServer Automacao</h1></div>");
  client.println("<div class='Principal'>");
 
}

void Inputs(Client client)
{
  client.print("<div class='BlocoMonitorEntrada'><div class='BlocoItensMonitor'>");
  client.print("Entradas Analogicas<br/>"); 
  client.println("<br/>");
  for (int analogChannel = 0; analogChannel <=5; analogChannel++) {
      client.print("<span>Entrada Analogica ");
      client.print(analogChannel);
      client.print(" = ");
      client.print(analogRead(analogChannel));
      client.println("</span><br/>");
  }          
  client.println("<br/><br/><br/>");
  client.print("Entradas Digitais<br/>"); 
  client.println("<br/>");      
    for (int digitalChannel = 8; digitalChannel <= 9; digitalChannel++) {
      client.print("<span>Entrada Digital ");
      client.print(digitalChannel-8);
      client.print(" = ");
      client.print(digitalRead(digitalChannel));
      client.println("</span><br/>");
    }    
  client.print("</div>");  
  client.print("</div>");  
}

void Outputs(Client client)
{
  client.print("<div class='BlocoMonitorEntrada'><div class='BlocoItensMonitor'>");
  client.print("Saidas Digitais<br/><br/>");         

    for (int digitalChannel = 0; digitalChannel <= 7; digitalChannel++) {
      
      client.print("<div class='IcoSaida' style='background-color:");                                    
      if(digitalRead(digitalChannel) == 1)
              client.print("red;'></div>");        
      else        
              client.print("lightgray;'></div>");   
              
      client.print("<span>Saida Digital&nbsp;");
      client.print(digitalChannel);
      client.print(" = ");
      client.print(digitalRead(digitalChannel));
      client.println("</span>");      
      client.print("<A HREF ='http://192.168.1.70/IS");
      client.print(digitalChannel);
      if(digitalRead(digitalChannel) == 1)
        client.print("0");
      else  
        client.print("1");
      client.print("'>&nbsp;Alterar saida</A>");

      client.print("");
      client.println("<br/>");      
    }
}

void Footer(Client client)
{
  client.println("</div></div></body></html>");
}


void PrintData(){
    
  int rtc[7];
  ds1307get(rtc,true);
  
  lcd.setCursor(0, 3);    
  if (rtc[HORAS] < 10){
  lcd.print("0");        
  } 
  lcd.print(rtc[HORAS],DEC);    
  lcd.setCursor(2, 3);  
  lcd.print(":");
  lcd.setCursor(3, 3);  
  if (rtc[MINUTOS] < 10){
  lcd.print("0");        
  } 
  lcd.print(rtc[MINUTOS],DEC);  
  lcd.setCursor(5, 3);  
  lcd.print(":");               
  lcd.setCursor(6, 3);  
  if (rtc[SEGUNDOS] < 10){
  lcd.print("0");        
  } 
  lcd.print(rtc[SEGUNDOS],DEC); 
  lcd.setCursor(8, 3);  
  lcd.print("  ");
  lcd.setCursor(10, 3); 
  if (rtc[DIAMES] < 10){
  lcd.print("0");        
  } 
  lcd.print(rtc[DIAMES],DEC); 
  lcd.setCursor(12, 3); 
  lcd.print("/");   
  lcd.setCursor(13, 3); 
  if (rtc[MES] < 10){
  lcd.print("0");        
  } 
  lcd.print(rtc[MES],DEC); 
  lcd.setCursor(15, 3); 
  lcd.print("/");   
  lcd.setCursor(16, 3); 
  lcd.print(rtc[ANO],DEC); 

}


void buzz(int targetPin, long frequency, long length) {
  long delayValue = 1000000/frequency/2; // calculate the delay value between transitions
  //// 1 second's worth of microseconds, divided by the frequency, then split in half since
  //// there are two phases to each cycle
  long numCycles = frequency * length/ 1000; // calculate the number of cycles for proper timing
  //// multiply frequency, which is really cycles per second, by the number of seconds to 
  //// get the total number of cycles to produce
 for (long i=0; i < numCycles; i++){ // for the calculated length of time...
    digitalWrite(targetPin,HIGH); // write the buzzer pin high to push out the diaphram
    delayMicroseconds(delayValue); // wait for the calculated delay value
    digitalWrite(targetPin,LOW); // write the buzzer pin low to pull back the diaphram
    delayMicroseconds(delayValue); // wait againf or the calculated delay value
  }
}


 
