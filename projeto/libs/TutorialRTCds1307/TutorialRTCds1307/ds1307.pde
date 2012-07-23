//-------Rotinas para ds1307 - i2c por Daniel Gonçalves a.k.a. Tr3s------
// Podem usar estas rotinas à vontade para projectos particulares. 
// Para fins comerciais entrar em contacto com we_real_cool@hotmail.com
// Partilhem com apenas com o meu consentimento. 
// Se virem este código noutro sitio sem ser www.lusorobotica.com avisem de imediato para we_real_cool@hotmail.com!

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

// Atençao que estes próximos valores não são os valores definidos no _RTC, são mais Offsets
#define DS1307_SEG  0   // Definir o valor offset, segundos
#define DS1307_MIN  1   // Definir o valor offset, minutos
#define DS1307_HR   2    // Definir o valor offset, horas
#define DS1307_DdS  3   // Definir o valor offset, dia da semana (tr3s claro)
#define DS1307_DMES 4  // Definir o valor offset, dia do mês
#define DS1307_MTH  5   // Definir o valor offset, mês
#define DS1307_ANO  6   // Definir o valor offset, ano

#define DS1307_BASE_ANO 2000 // Base do ano, se quisermos definir 2033 por exemplo, só temos de dizer que é o ano 33

int rtc_bcd[7];  // Este array vai receber os valores do ds1307 em BCD

void ds1307setup(void){     // Acertar tudo no relógio e iniciá-lo
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

void ds1307read(void){     // Esta função pede os dados ao ds1307, recebos em BCD e actualiza o array rtc_bcd
  Wire.beginTransmission(DS1307_I2C_ID);
  Wire.send(0x00);
  Wire.endTransmission();

  Wire.requestFrom(DS1307_I2C_ID, 7);              // Pedir 7 bytes: segs, min, hr, dsem, dmes, mes, ano.
  for(byte i=0; i<7; i++)rtc_bcd[i]=Wire.receive(); // Guardar dados no array
}

void ds1307save(void){                            // Funçao para guardar os dados que estão no array no ds1307
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

void ds1307stop(void){    // Parar o ds1307... "A sério? Pelo nome não ia lá sabes..."
    rtc_bcd[DS1307_SEG]=rtc_bcd[DS1307_SEG] | DS1307_CLOCKHALT;
    ds1307save();
}

void ds1307start(void){   // "Espera, espera! Deixa-me adivinhar! Esta função é para fazer o ds1307 começar!? ..." - HMM, é... - "Nós percebemos... DUUUH "
    rtc_bcd[DS1307_SEG]=0;
    ds1307save();
}

// Por Daniel Gonçalves a.k.a. (t.c.p.) Tr3s, para www.lusorobotica.com
