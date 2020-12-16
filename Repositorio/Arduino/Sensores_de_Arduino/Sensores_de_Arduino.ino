#include <SoftwareSerial.h>//libreria de comunicacion serial uart
#include <mlx90615.h> // libreria para el sensor de temperatura a distancia 
#include <Wire.h> // averiguar 
#include <SPI.h> // averiguar 
#include <MFRC522.h>
const int Trigger = 2;   //Pin digital 2 para el Trigger del sensor
const int Echo = 3;   //Pin digital 3 para el Echo del sensor
#define RST_PIN  9    //Pin 9 para el reset del RC522
#define SS_PIN  10   //Pin 10 para el SS (SDA) del RC522
MFRC522 mfrc522(SS_PIN, RST_PIN); ///Creamos el objeto para el RC522
MLX90615 mlx = MLX90615(); // definimos el sensor de la libreria 
SoftwareSerial TEMPERATURA(A0,A1);//RX Y TX esto lo usamos para definir una nueva linea de datos que sera la que trasmitira la informacion del sensor de temperatura
SoftwareSerial RFID(4,5);//RX Y TX esto lo usamos para definir una nueva linea de datos que sera la que trasmitira la informacion del rfid 
SoftwareSerial ULTRASONIDO(6,7);//RX Y TX esto lo usamos para definir una nueva linea de datos que sera la que trasmitira la informacion del sensor de ultrasonido
int loc = 1;
void setup (){
TEMPERATURA.begin (9600); //comunicacion serial define la velocidad de comunicacion del sensor de temperatura
RFID.begin (9600); //comunicacion serial define la velocidad de comunicacion del rfid
ULTRASONIDO.begin (9600); //comufnicacion serial define la velocidad de comunicacion del sensor de ultrasonido
Serial.begin (9600); //comunicacion serial para el computador 
mlx.begin();// como el sensor es i2c pues debemos leerlo 
  SPI.begin();        //Iniciamos el Bus SPI
  mfrc522.PCD_Init(); // Iniciamos el MFRC522
  Serial.println("Control de acceso:");
  pinMode(Trigger, OUTPUT); //pin como salida
  pinMode(Echo, INPUT);  //pin como entrada
  digitalWrite(Trigger, LOW);//Inicializamos el pin con 0
}
byte ActualUID[4]; //almacenará el código del Tag leído
byte Usuario1[4]= {0x0E, 0xBC, 0x6F, 0x51} ; //CAMBIAR EL CODIGO USEN EL MONTAJE BASE Y LEEN LAS TARJETAS 
byte Usuario2[4]= {0xC1, 0x2F, 0xD6, 0x0E} ; //CAMBIAR EL CODIGO USEN EL MONTAJE BASE Y LEEN LAS TARJETAS 
void loop (){
  //entrega en el computador la lectura del sensor de temperatura 
 // Serial.print("Ambient = ");
 // Serial.print(mlx.get_ambient_temp()); 
 // Serial.print(" *C\tObject = ");
 int x = mlx.get_object_temp();
 // Serial.println(x, HEX);//nota mirar los decimales asci a hexadecimal 
  //  Serial.print("TEMPERATURA: ");
  //  Serial.print(x);
 // Serial.println(" *C");
// finaliza lo del pc pasamos a trasmitirlo en la linea 1 
//TEMPERATURA.print(x); //ESTO HACE QUE SE ESCRIBA POR UART A TRAVES DE LOS PINES LA INFORMACION 
//TEMPERATURA.println(mlx.get_object_temp(),BIN); ESTO ESCRIBIRA EN BINARIO LA SALIDA 0 Y 1
//INICIO DE ULTRASONIDO
long t; //timepo que demora en llegar el eco
  int d; //distancia en centimetros
  digitalWrite(Trigger, HIGH);
  delayMicroseconds(10);          //Enviamos un pulso de 10us
  digitalWrite(Trigger, LOW);
  t = pulseIn(Echo, HIGH); //obtenemos el ancho del pulso
  d = t/59;             //escalamos el tiempo a una distancia en cm
//  ULTRASONIDO.print(d);//esto lo enviara en codigo ASCI 
  delay(100);          //Hacemos una pausa de 100ms
  //FIN
//RFID INICIO
if ( mfrc522.PICC_IsNewCardPresent()) {  
      //Seleccionamos una tarjeta
            if ( mfrc522.PICC_ReadCardSerial()) {
                  // Enviamos serialemente su UID
                  // Serial.print(F("Card UID:")); descomentar para saber el cofigo rfid
                  for (byte i = 0; i < mfrc522.uid.size; i++) {
                         // Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "); //y esta
                          //Serial.print(mfrc522.uid.uidByte[i], HEX);   //y esta
                          ActualUID[i]=mfrc522.uid.uidByte[i];          
                  } 
                  //Serial.print("     ");                 
                  //comparamos los UID para determinar si es uno de nuestros usuarios  
                  if(compareArray(ActualUID,Usuario1)){
                 //   Serial.print("Acceso concedido...    ");
                 //   RFID.print("Acceso concedido");
                    loc = 0;   
                    
                    //RFID.println(0,BIN); ESTO ESCRIBIRA EN BINARIO LA SALIDA 0 Y 1
                  }
                  else if(compareArray(ActualUID,Usuario2)){
                 //   Serial.print("Acceso concedido...    ");
                  //  RFID.print("CONCEDIDO");
                    //RFID.println(0,BIN); ESTO ESCRIBIRA EN BINARIO LA SALIDA 0 Y 1
                    loc = 0; 
                  }
                  else
                   // Serial.print("Acceso denegado...     ");
                   //  RFID.print("Acceso denegado...");
                     loc = 1; 
                     //ACTIVAR LA SIGUIENTE LINEA ES MAS SENCILLA 
                     //RFID.println(1,BIN); ESTO ESCRIBIRA EN BINARIO LA SALIDA 0 Y 1
                  // Terminamos la lectura de la tarjeta tarjeta  actual
                  mfrc522.PICC_HaltA();
                  }
            } 
            if((2<d)&&(d<15)&&(x<39)&&(loc == 0)){            
              ULTRASONIDO.print(d);//ULTRASONIDO.print(d,HEX);
              TEMPERATURA.print(x);//TEMPERATURA.print(x, HEX);
              RFID.print("SIGA");//RFID.print("SIGA");
              }
                          if((2<d)&&(d<15)&&(x<39)&&(loc == 0)){
                            Serial.print("distancia: ");//ULTRASONIDO.print(d,HEX);
              Serial.print(d);//ULTRASONIDO.print(d,HEX);
                Serial.print("  temperatura:  ");//ULTRASONIDO.print(d,HEX);
              Serial.print(x);//TEMPERATURA.print(x, HEX);
                Serial.print("   ");//ULTRASONIDO.print(d,HEX);
              Serial.println("acceso concedido");//RFID.print("SIGA");
              }
  }
  


//Función para comparar dos vectores
 boolean compareArray(byte array1[],byte array2[])
{
  if(array1[0] != array2[0])return(false);
  if(array1[1] != array2[1])return(false);
  if(array1[2] != array2[2])return(false);
  if(array1[3] != array2[3])return(false);
  return(true);
}
