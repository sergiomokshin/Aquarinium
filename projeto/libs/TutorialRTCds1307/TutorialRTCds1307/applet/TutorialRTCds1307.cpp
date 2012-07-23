#include <Wire.h>       // Para a EEPROM 24LC256 DS1621 DS1307 e dispositivos i2c

#define HORAS 2         // S\u00e3o os mesmos valores que est\u00e3o definidos no ficheiro ds1307.pde, os de offset
#define MINUTOS 1
#define SEGUNDOS 0   
#define DIASEMANA 3     // QUAL \u00c9 O MELHOR N\u00daMERO? :D
#define DIAMES 4  
#define MES 5 
#define ANO 6 

#include "WProgram.h"
void setup(void);
void loop();
void printData();
void ds1307setup(void);
void ds1307read(void);
void ds1307save(void);
void ds1307get(int *rtc, boolean refresh);
int ds1307get(byte c, boolean refresh);
void ds1307set(byte c, byte v);
void ds1307stop(void);
void ds1307start(void);
void setup(void){
  Serial.begin(9600);   // Valor pequeno mas bom, eu gosto assim :D
  Wire.begin();         // Iniciar liga\u00e7\u00f5es i2c - IMPORTANT\u00cdSSIMO
  ds1307setup();        // Se for a primeira vez que o RTC \u00e9 iniciado/ligado esta chamada \u00e9 necess\u00e1ria para o RTC come\u00e7ar a contar
}

void loop(){
  printData();
  delay(1000);
  
}

void printData(){
  int rtc[7];
  ds1307get(rtc,true);
  Serial.print("Sao:    ");
  Serial.print(rtc[HORAS],DEC);    // em primeiro v\u00eam as horas...
  Serial.print(":");               // ...
  Serial.print(rtc[MINUTOS],DEC);  // Agora os minutos...
  Serial.print(":");               // ...
  Serial.print(rtc[SEGUNDOS],DEC); // E de seguida os segundos. Vamos agora \u00e0s estrelas... (Ai Marisa... (.)(.) )
  // Um textito para ficar bonito quando se mostra \u00e0 fam\u00edlia!
  switch(rtc[DIASEMANA]){
    case 0:Serial.print("   Domingo"); break;        //para mim a semana come\u00e7a ao Domingo :P
    case 1:Serial.print("   Segunda-feira"); break;
    case 2:Serial.print("   Ter\u00e7a-feira"); break;
    case 3:Serial.print("   Quarta-feira"); break;
    case 4:Serial.print("   Quinta-feira"); break;
    case 5:Serial.print("   Sexta-feira"); break;
    case 6:Serial.print("   Sabado"); break;
    default:Serial.print("   DiaDeSaoNunca-feira");  //Se vier aqui... aguentem :D \u00e9 feriado! Ahaha
  }
  Serial.print(" dia ");
  Serial.print(rtc[DIAMES]);  // Este \u00e9 o dia do mes caso n\u00e3o d\u00ea para entender XD, n\u00e3o fa\u00e7o tratamento dos dias por isso pode dar dia 0 ou 9999
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
    default:Serial.print(" Oufevulhosto");  //Se vier aqui... \u00e9 aquele 13\u00ba m\u00eas vamos receber mais $ :D! 
  }
  Serial.print(" de ");
  Serial.println(rtc[ANO],DEC);  // Yaeih acabou! 
}

//-------Rotinas para ds1307 - i2c por Daniel Gon\u00e7alves a.k.a. Tr3s------
// Podem usar estas rotinas \u00e0 vontade para projectos particulares. 
// Para fins comerciais entrar em contacto com we_real_cool@hotmail.com
// Partilhem com apenas com o meu consentimento. 
// Se virem este c\u00f3digo noutro sitio sem ser www.lusorobotica.com avisem de imediato para we_real_cool@hotmail.com!

#define DS1307_I2C_ID 0x68  // ID no bus i2c do RTC ds1307

// Mascaras para aceder aos registos
#define DS1307_CLOCKHALT 0x80
#define DS1307_LO_BCD    0x0F
#define DS1307_HI_BCD    0xF0
#define DS1307_HI_SEG    0x70
#define DS1307_HI_MIN    0x70
#define DS1307_HI_HR     0x30
#define DS1307_LO_DdS    0x07
#define DS1307_HI_DMES   0x30
#define DS1307_HI_MES    0x30
#define DS1307_HI_ANO   0xF0

// Aten\u00e7ao que estes pr\u00f3ximos valores n\u00e3o s\u00e3o os valores definidos no _RTC, s\u00e3o mais Offsets
#define DS1307_SEG  0   // Definir o valor offset, segundos
#define DS1307_MIN  1   // Definir o valor offset, minutos
#define DS1307_HR   2    // Definir o valor offset, horas
#define DS1307_DdS  3   // Definir o valor offset, dia da semana (tr3s claro)
#define DS1307_DMES 4  // Definir o valor offset, dia do m\u00eas
#define DS1307_MTH  5   // Definir o valor offset, m\u00eas
#define DS1307_ANO  6   // Definir o valor offset, ano

#define DS1307_BASE_ANO 2000 // Base do ano, se quisermos definir 2033 por exemplo, s\u00f3 temos de dizer que \u00e9 o ano 33

int rtc_bcd[7];  // Este array vai receber os valores do ds1307 em BCD

void ds1307setup(void){     // Acertar tudo no rel\u00f3gio e inici\u00e1-lo
  ds1307stop();
  ds1307set(DS1307_SEG,1);  // Altera estes valores e quiseres iniciar o RTC com outra data
  ds1307set(DS1307_MIN,15);
  ds1307set(DS1307_HR,23);
  ds1307set(DS1307_DdS,4);
  ds1307set(DS1307_DMES,12);
  ds1307set(DS1307_MTH,2);
  ds1307set(DS1307_ANO,9);
  ds1307start();
}

void ds1307read(void){     // Esta fun\u00e7\u00e3o pede os dados ao ds1307, recebos em BCD e actualiza o array rtc_bcd
  Wire.beginTransmission(DS1307_I2C_ID);
  Wire.send(0x00);
  Wire.endTransmission();

  Wire.requestFrom(DS1307_I2C_ID, 7);              // Pedir 7 bytes: segs, min, hr, dsem, dmes, mes, ano.
  for(byte i=0; i<7; i++)rtc_bcd[i]=Wire.receive(); // Guardar dados no array
}

void ds1307save(void){                            // Fun\u00e7ao para guardar os dados que est\u00e3o no array no ds1307
  Wire.beginTransmission(DS1307_I2C_ID);
  Wire.send(0x00);                                // Fazer reset ao ponteiro interno do ds1307
  for(byte i=0; i<7; i++)Wire.send(rtc_bcd[i]);   // Gravar os "ditos cujos"
  Wire.endTransmission();
}

void ds1307get(int *rtc, boolean refresh){       // Adquire os dados do array rtc_bcd e converte-os para int, se pretendido, actualiza o array.
  if(refresh) ds1307read();
  for(byte i=0;i<7;i++)rtc[i]=ds1307get(i, 0);   // Percorre cada elemento do array e actualiza-o
}

int ds1307get(byte c, boolean refresh){  // Adquire cada elemento da data, retorna esse valor como int e actualiza o array se pedido
  if(refresh) ds1307read();
  int v=-1;                              // Se der "fezes" tem de retornar um valor absurdo...
  switch(c){
  case DS1307_SEG:
    v=(10*((rtc_bcd[DS1307_SEG] & DS1307_HI_SEG)>>4))+(rtc_bcd[DS1307_SEG] & DS1307_LO_BCD);
	break;
  case DS1307_MIN:
    v=(10*((rtc_bcd[DS1307_MIN] & DS1307_HI_MIN)>>4))+(rtc_bcd[DS1307_MIN] & DS1307_LO_BCD);
	break;
  case DS1307_HR:
    v=(10*((rtc_bcd[DS1307_HR] & DS1307_HI_HR)>>4))+(rtc_bcd[DS1307_HR] & DS1307_LO_BCD);
	break;
  case DS1307_DdS:
    v=rtc_bcd[DS1307_DdS] & DS1307_LO_DdS;
	break;
  case DS1307_DMES:
    v=(10*((rtc_bcd[DS1307_DMES] & DS1307_HI_DMES)>>4))+(rtc_bcd[DS1307_DMES] & DS1307_LO_BCD);
	break;
  case DS1307_MTH:
    v=(10*((rtc_bcd[DS1307_MTH] & DS1307_HI_MES)>>4))+(rtc_bcd[DS1307_MTH] & DS1307_LO_BCD);
	break;
  case DS1307_ANO:
    v=(10*((rtc_bcd[DS1307_ANO] &  DS1307_HI_ANO)>>4))+(rtc_bcd[DS1307_ANO] & DS1307_LO_BCD)+DS1307_BASE_ANO;
	break;
  }
  return v;
}

void ds1307set(byte c, byte v){  // Actualiza o array e o ds1307
  switch(c){
  case DS1307_SEG:
    if(v<60 && v>-1){            // Desta forma consegue-se manter o clock actual
		byte state=rtc_bcd[DS1307_SEG] & DS1307_CLOCKHALT;
		rtc_bcd[DS1307_SEG]=state | ((v / 10)<<4) + (v % 10);
    }
    break;
  case DS1307_MIN:
    if(v<60 && v>-1)rtc_bcd[DS1307_MIN]=((v / 10)<<4) + (v % 10);
    break;
  case DS1307_HR:
  // TODO : AM/PM  12HR/24HR
    if(v<24 && v>-1) rtc_bcd[DS1307_HR]=((v / 10)<<4) + (v % 10);
    break;
  case DS1307_DdS:
    if(v<8 && v>-1)rtc_bcd[DS1307_DdS]=v;
    break;
  case DS1307_DMES:
    if(v<=31 && v>-1)rtc_bcd[DS1307_DMES]=((v / 10)<<4) + (v % 10);
    break;
  case DS1307_MTH:
    if(v<13 && v>-1)rtc_bcd[DS1307_MTH]=((v / 10)<<4) + (v % 10);
    break;
  case DS1307_ANO:
    if(v<130 && v>-1)rtc_bcd[DS1307_ANO]=((v / 10)<<4) + (v % 10);
    break;
  }
  ds1307save();
}

void ds1307stop(void){    // Parar o ds1307... "A s\u00e9rio? Pelo nome n\u00e3o ia l\u00e1 sabes..."
    rtc_bcd[DS1307_SEG]=rtc_bcd[DS1307_SEG] | DS1307_CLOCKHALT;
    ds1307save();
}

void ds1307start(void){   // "Espera, espera! Deixa-me adivinhar! Esta fun\u00e7\u00e3o \u00e9 para fazer o ds1307 come\u00e7ar!? ..." - HMM, \u00e9... - "N\u00f3s percebemos... DUUUH "
    rtc_bcd[DS1307_SEG]=0;
    ds1307save();
}

// Por Daniel Gon\u00e7alves a.k.a. (t.c.p.) Tr3s, para www.lusorobotica.com

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

