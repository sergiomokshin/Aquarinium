/*

Biblioteca p/ RTC Dallas DS1307

*/

// ID no bus i2c do RTC ds1307
#define DS1307_I2C_ID 0x68  

// Mascaras para acesso aos registos
#define DS1307_CLOCKHALT 0x80
#define DS1307_LO_BCD    0x0F
#define DS1307_HI_BCD    0xF0
#define DS1307_HI_SEG    0x70
#define DS1307_HI_MIN    0x70
#define DS1307_HI_HR     0x30
#define DS1307_LO_DdS    0x07
#define DS1307_HI_DMES   0x30
#define DS1307_HI_MES    0x30
#define DS1307_HI_ANO    0xF0

// Offsets para acesso aos registros do chip
#define DS1307_SEG  0 // Definir o valor offset, segundos
#define DS1307_MIN  1 // Definir o valor offset, minutos
#define DS1307_HR   2 // Definir o valor offset, horas
#define DS1307_DdS  3 // Definir o valor offset, dia da semana (tr3s claro)
#define DS1307_DMES 4 // Definir o valor offset, dia do m�s
#define DS1307_MTH  5 // Definir o valor offset, m�s
#define DS1307_ANO  6 // Definir o valor offset, ano

#define DS1307_BASE_ANO 2000 // Base do ano

int rtc_bcd[7]; // Array vai receber os valores do ds1307 em BCD

void ds1307setup(void){     // Acertar tudo no rel�gio e inici�-lo
  ds1307stop();
  ds1307set(DS1307_SEG,0);  // Altera estes valores se quiser iniciar o RTC com outra hora e data
  ds1307set(DS1307_MIN,33);
  ds1307set(DS1307_HR,20);
  ds1307set(DS1307_DdS,22);
  ds1307set(DS1307_DMES,22);
  ds1307set(DS1307_MTH,6);
  ds1307set(DS1307_ANO,12);
  ds1307start();
}

void ds1307read(void){  // Esta função lê os dados do ds1307, recebe-os em BCD e atualiza a array rtc_bcd
  Wire.beginTransmission(DS1307_I2C_ID);
  Wire.send(0x00);
  Wire.endTransmission();
  Wire.requestFrom(DS1307_I2C_ID, 7); // Pedir 7 bytes: segs, min, hr, dsem, dmes, mes, ano.
  for(byte i=0; i<7; i++)rtc_bcd[i]=Wire.receive(); // Guardar dados no array
}

void ds1307save(void){ // Esta função grava os dados que estão na array rtc_bcd no ds1307
  Wire.beginTransmission(DS1307_I2C_ID);
  Wire.send(0x00); // Reseta o ponteiro interno do ds1307
  for(byte i=0; i<7; i++)Wire.send(rtc_bcd[i]); // Gravar os dados
  Wire.endTransmission();
}

void ds1307get(int *rtc, boolean refresh){ // Obtem os dados da array rtc_bcd e converte-os para int
  if(refresh) ds1307read();
  for(byte i=0;i<7;i++)rtc[i]=ds1307get(i, 0);   // Percorre cada elemento do array e actualiza-o
}

int ds1307get(byte c, boolean refresh){  // Obtem cada elemento da data, retorna esse valor como int e atualiza a array
  if(refresh) ds1307read();
  int v=-1;
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

void ds1307set(byte c, byte v){  // Atualiza a array e o ds1307
  switch(c){
    case DS1307_SEG:
      if(v<60 && v>-1){ 
	byte state=rtc_bcd[DS1307_SEG] & DS1307_CLOCKHALT;
	rtc_bcd[DS1307_SEG]=state | ((v / 10)<<4) + (v % 10);
      }
    break;
    case DS1307_MIN:
      if(v<60 && v>-1)rtc_bcd[DS1307_MIN]=((v / 10)<<4) + (v % 10);
    break;
    case DS1307_HR:
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

void ds1307stop(void){ // Parar o ds1307
  rtc_bcd[DS1307_SEG]=rtc_bcd[DS1307_SEG] | DS1307_CLOCKHALT;
  ds1307save();
}

void ds1307start(void){
  rtc_bcd[DS1307_SEG]=0;
  ds1307save();
}
