#include <Wire.h>       // Para a EEPROM 24LC256 DS1621 DS1307 e dispositivos i2c

#define HORAS 2         // São os mesmos valores que estão definidos no ficheiro ds1307.pde, os de offset
#define MINUTOS 1
#define SEGUNDOS 0   
#define DIASEMANA 3     // QUAL É O MELHOR NÚMERO? :D
#define DIAMES 4  
#define MES 5 
#define ANO 6 

void setup(void){
  Serial.begin(9600);   // Valor pequeno mas bom, eu gosto assim :D
  Wire.begin();         // Iniciar ligações i2c - IMPORTANTÍSSIMO
  ds1307setup();        // Se for a primeira vez que o RTC é iniciado/ligado esta chamada é necessária para o RTC começar a contar
}

void loop(){
  printData();
  delay(1000);
  
}

void printData(){
  int rtc[7];
  ds1307get(rtc,true);
  Serial.print("Sao:    ");
  Serial.print(rtc[HORAS],DEC);    // em primeiro vêm as horas...
  Serial.print(":");               // ...
  Serial.print(rtc[MINUTOS],DEC);  // Agora os minutos...
  Serial.print(":");               // ...
  Serial.print(rtc[SEGUNDOS],DEC); // E de seguida os segundos. Vamos agora às estrelas... (Ai Marisa... (.)(.) )
  // Um textito para ficar bonito quando se mostra à família!
  switch(rtc[DIASEMANA]){
    case 0:Serial.print("   Domingo"); break;        //para mim a semana começa ao Domingo :P
    case 1:Serial.print("   Segunda-feira"); break;
    case 2:Serial.print("   Terça-feira"); break;
    case 3:Serial.print("   Quarta-feira"); break;
    case 4:Serial.print("   Quinta-feira"); break;
    case 5:Serial.print("   Sexta-feira"); break;
    case 6:Serial.print("   Sabado"); break;
    default:Serial.print("   DiaDeSaoNunca-feira");  //Se vier aqui... aguentem :D é feriado! Ahaha
  }
  Serial.print(" dia ");
  Serial.print(rtc[DIAMES]);  // Este é o dia do mes caso não dê para entender XD, não faço tratamento dos dias por isso pode dar dia 0 ou 9999
  Serial.print(" de");
    switch(rtc[MES]){
    case 0:Serial.print(" Janeiro"); break;      
    case 1:Serial.print(" Fevereiro"); break;
    case 2:Serial.print(" Marco"); break;
    case 3:Serial.print(" Abril"); break;
    case 4:Serial.print(" Maio"); break;
    case 5:Serial.print(" Junho"); break;
    case 6:Serial.print(" Julho"); break;
    case 7:Serial.print(" Agosto"); break;
    case 8:Serial.print(" Setembro"); break;
    case 9:Serial.print(" Outubro"); break;
    case 10:Serial.print(" Novembro"); break;
    case 11:Serial.print(" Dezembro"); break;
    default:Serial.print(" Oufevulhosto");  //Se vier aqui... é aquele 13º mês vamos receber mais $ :D! 
  }
  Serial.print(" de ");
  Serial.println(rtc[ANO],DEC);  // Yaeih acabou! 
}
