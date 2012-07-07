/*
  Web  Server

 criado em 09/02/2012
 Adaptação WebServer para monitoramento de entradas análogicas, digitais e acionamento de saídas digitais
 por Sérgio de Miranda e Castro Mokshin
 

 Protocolo para acionar saída
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

 
 
 */
#define BUFSIZ 100
#include <SPI.h>
#include <Ethernet.h>
#include <stdio.h>
#include <stdlib.h> 
#include <LiquidCrystal.h>
#include <Keypad.h>

#define PIN_BLUE 7
#define PIN_RED 8
#define PIN_GREEN 9

#define PIN_SAIDA_BOMBA 31
#define PIN_SAIDA_TERMO 33
#define PIN_SAIDA_AUX1 35
#define PIN_SAIDA_AUX2 37


#define PIN_ENTRADA_NIVEL_B 39
#define PIN_ENTRADA_NIVEL_A 41

#define PIN_ENTRADA_TEMP 0

const byte ROWS = 4; //four rows
const byte COLS = 3; //three columns
char keys[ROWS][COLS] = {
  {'1','2','3'},
  {'4','5','6'},
  {'7','8','9'},
  {'#','0','*'}
};
byte rowPins[ROWS] = {32, 22, 24, 28}; //connect to the row pinouts of the keypad
byte colPins[COLS] = {30, 34, 26}; //connect to the column pinouts of the keypad

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

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup()
{
  
  Serial.begin(9600);
  
  pinMode(PIN_ENTRADA_NIVEL_B, INPUT);
  pinMode(PIN_ENTRADA_NIVEL_A, INPUT);
 // pinMode(PIN_ENTRADA_TEMP, INPUT);
  
  pinMode(PIN_SAIDA_BOMBA, OUTPUT);     
  pinMode(PIN_SAIDA_TERMO, OUTPUT);     
  pinMode(PIN_SAIDA_AUX1, OUTPUT);     
  pinMode(PIN_SAIDA_AUX2, OUTPUT);     

  digitalWrite(PIN_SAIDA_BOMBA, LOW);
  digitalWrite(PIN_SAIDA_TERMO, LOW);
  digitalWrite(PIN_SAIDA_AUX1, LOW);
  digitalWrite(PIN_SAIDA_AUX2, LOW);
 
  Serial.begin(9600);
  Ethernet.begin(mac, ip);
  server.begin();
  inicioComando1 = false;
  inicioFuncaoTeclado = false;
  inicioComandoTeclado = false;
  inicioComando2 = false;
  fimComando = false;
  recebendoComandoWeb = false;
  indiceentrada = 0;
  
  
  lcd.begin(20, 4);
  lcd.print("     AQUARINIUM     ");
  lcd.setCursor(0, 1);
  lcd.print("Aguardando Dados!");
 
}

void loop()
{
   
 
  AguardaComandosTeclado();
  AguardaComandosWEB(); 
  //LerTemperatura();          
}

void AguardaComandosTeclado()
{   
  char key = keypad.getKey();
  if (key != NO_KEY){    
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
              lcd.print("Bomba 0:ON = 1:OFF  ");
              break;
          case '5':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'S';
              index++;
              clientline[index] = '3';                           
              break;
              lcd.print("Termo 0:ON = 1':OFF  ");      
          case '6':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'S';
              index++;
              clientline[index] = '2'; 
              lcd.print("Saida1 1:ON = 0:OFF ");
              break;
          case '7':
              clientline[index] = 'I';         
              index++;
              clientline[index] = 'S';
              index++;
              clientline[index] = '1';   
              lcd.print("Saida2 1:ON = 0:OFF ");
              break;
          case '8':
              lcd.print("Manual 1:ON = 0:OFF ");
        	 break;
          case '0':
              lcd.print("Auto 1:ON = 0:OFF   ");
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
    
     case '1':
	 digitalWrite(PIN_SAIDA_BOMBA, nivel);
	 break;
     case '2':
	 digitalWrite(PIN_SAIDA_TERMO, nivel);
	 break;
     case '3':
	 digitalWrite(PIN_SAIDA_AUX1, nivel);
	 break;
     case '4':
	 digitalWrite(PIN_SAIDA_AUX2, nivel);
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






 