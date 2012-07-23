/*

Código fonte de exemplo para uso com a Placa Arduino Bricks RTC fabricada pela Zuchi

Este código de exemplo é de domínio público

Autor: Pedro Zuchi - pedro@zuchi.com.br
Loja Virtual: www.zuchishop.com.br, www.zuchi.com.br
Área de download: www.zuchi.com.br/download
Blog: www.androidarduino.com.br, www.androidioio.com.br

Observações:
Este exemplo faz uso de uma Placa Arduino Duemilanove e uma Placa Arduino Bricks RTC
Portas da Placa Arduino Duemilanove utilizadas no exemplo:
Sinal SDA - Analog Input 7
Sinal SCL - Analog Input 6

*/

#include <Wire.h>       // Include necessário para dispositivos I2C Bus

#define SEGUNDOS 0     // Definição dos indices para leitura dos dados do RTC
#define MINUTOS 1
#define HORAS 2         
#define DIASEMANA 3 
#define DIAMES 4  
#define MES 5 
#define ANO 6 

// Função setup
void setup(void){
  Serial.begin(9600);   // Inicialização da porta serial
  Wire.begin();         // Inicialização do barramento I2C
  // Após a colocação da bateria no RTC, é necessário acertar o calendário e o relógio
  // do mesmo para que este comece a operar adequadamente para isto, compile este exemplo
  // uma primeira vez com a linha de código a seguir e carregue-o na placa Duemilanove.
  // Após este procedimento, comente a linha, recompile o programa mais uma vez e
  // recarregue-o na placa Duemilanove.
  // Para ajuste a data e a hora do RTC veja a função ds1307setup() no arquivo ds1307.pde
  //ds1307setup();
}

// Função loop
void loop(){
  printData();
  delay(1000);  
}

// Função imprime hora e data
void printData(){
  int rtc[7];
  ds1307get(rtc,true);
  Serial.print("Sao:    ");
  Serial.print(rtc[HORAS],DEC);
  Serial.print(":"); 
  Serial.print(rtc[MINUTOS],DEC);
  Serial.print(":"); 
  Serial.print(rtc[SEGUNDOS],DEC);
  switch(rtc[DIASEMANA]){
    case 0:Serial.print("   Domingo"); break;
    case 1:Serial.print("   Segunda-feira"); break;
    case 2:Serial.print("   Ter�a-feira"); break;
    case 3:Serial.print("   Quarta-feira"); break;
    case 4:Serial.print("   Quinta-feira"); break;
    case 5:Serial.print("   Sexta-feira"); break;
    case 6:Serial.print("   Sabado"); break;
  }
  Serial.print(" dia ");
  Serial.print(rtc[DIAMES]);
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
  }
  Serial.print(" de ");
  Serial.println(rtc[ANO],DEC);
}
