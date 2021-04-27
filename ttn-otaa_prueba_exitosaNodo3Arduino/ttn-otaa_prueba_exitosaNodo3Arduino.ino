/*******************************************************************************
 * Copyright (c) 2015 Thomas Telkamp and Matthijs Kooijman
 *
 * Permission is hereby granted, free of charge, to anyone
 * obtaining a copy of this document and accompanying files,
 * to do whatever they want with them without any restriction,
 * including, but not limited to, copying, modification and redistribution.
 * NO WARRANTY OF ANY KIND IS PROVIDED.
 *
 * This example sends a valid LoRaWAN packet with payload "Hello,
 * world!", using frequency and encryption settings matching those of
 * the The Things Network.
 *
 * This uses OTAA (Over-the-air activation), where where a DevEUI and
 * application key is configured, which are used in an over-the-air
 * activation procedure where a DevAddr and session keys are
 * assigned/generated for use with all further communication.
 *
 * Note: LoRaWAN per sub-band duty-cycle limitation is enforced (1% in
 * g1, 0.1% in g2), but not the TTN fair usage policy (which is probably
 * violated by this sketch when left running for longer)!

 * To use this sketch, first register your application and device with
 * the things network, to set or generate an AppEUI, DevEUI and AppKey.
 * Multiple devices can use the same AppEUI, but each device has its own
 * DevEUI and AppKey.
 *
 * Do not forget to define the radio type correctly in config.h.
 *
 *******************************************************************************/

#include <lmic.h>
#include <hal/hal.h>
#include <SPI.h>

// This EUI must be in little-endian format, so least-significant-byte
// first. When copying an EUI from ttnctl output, this means to reverse
// the bytes. For TTN issued EUIs the last bytes should be 0xD5, 0xB3,
// 0x70.
static const u1_t PROGMEM APPEUI[8]={ 0x63, 0x5A, 0x02, 0xD0, 0x7E, 0xD5, 0xB3, 0x70 };//lsb
void os_getArtEui (u1_t* buf) { memcpy_P(buf, APPEUI, 8);}

// This should also be in little endian format, see above.
// 
static const u1_t PROGMEM DEVEUI[8]={ 0x4F, 0xB3, 0xAE, 0x44, 0x70, 0x18, 0x1D, 0x00 };//lsb
void os_getDevEui (u1_t* buf) { memcpy_P(buf, DEVEUI, 8);}

// This key should be in big endian format (or, since it is not really a
// number but a block of memory, endianness does not really apply). In
// practice, a key taken from ttnctl can be copied as-is.
// The key shown here is the semtech default key.
static const u1_t PROGMEM APPKEY[16] = { 0x34, 0x45, 0xEE, 0x44, 0xEC, 0xDA, 0x7B, 0x16, 0x87, 0x50, 0xE0, 0xA6, 0x46, 0x56, 0x62, 0x56 };//msb
void os_getDevKey (u1_t* buf) {  memcpy_P(buf, APPKEY, 16);}


//static uint8_t mydata[] = "que se dice Roita?";
static uint8_t payload[2];
static osjob_t sendjob;

// Schedule TX every this many seconds (might become longer due to duty
// cycle limitations).
const unsigned TX_INTERVAL = 60;

long duracion, distancia;   
float latitude, longitude;
int Ptrig, Pecho, respEcho;

// Pin mapping
const lmic_pinmap lmic_pins = {
    .nss = 10,
    .rxtx = LMIC_UNUSED_PIN,
    .rst = 5,
    .dio = {2, 3, 4},
};

void onEvent (ev_t ev) {
    Serial.print(os_getTime());
    Serial.print(": ");
    switch(ev) {
        case EV_SCAN_TIMEOUT:
            Serial.println(F("EV_SCAN_TIMEOUT"));
            break;
        case EV_BEACON_FOUND:
            Serial.println(F("EV_BEACON_FOUND"));
            break;
        case EV_BEACON_MISSED:
            Serial.println(F("EV_BEACON_MISSED"));
            break;
        case EV_BEACON_TRACKED:
            Serial.println(F("EV_BEACON_TRACKED"));
            break;
        case EV_JOINING:
            Serial.println(F("EV_JOINING"));
            break;
        case EV_JOINED:
            Serial.println(F("EV_JOINED"));

            // Disable link check validation (automatically enabled
            // during join, but not supported by TTN at this time).
            LMIC_setLinkCheckMode(0);
            break;
        case EV_RFU1:
            Serial.println(F("EV_RFU1"));
            break;
        case EV_JOIN_FAILED:
            Serial.println(F("EV_JOIN_FAILED"));
            break;
        case EV_REJOIN_FAILED:
            Serial.println(F("EV_REJOIN_FAILED"));
            break;
            break;
        case EV_TXCOMPLETE:
            Serial.println(F("EV_TXCOMPLETE (includes waiting for RX windows)"));
            if (LMIC.txrxFlags & TXRX_ACK)
              Serial.println(F("Received ack"));
            if (LMIC.dataLen) {
              Serial.println(F("Received "));
              Serial.println(LMIC.dataLen);
              Serial.println(F(" bytes of payload"));
            }
            // Schedule next transmission
            os_setTimedCallback(&sendjob, os_getTime()+sec2osticks(TX_INTERVAL), do_send);
            break;
        case EV_LOST_TSYNC:
            Serial.println(F("EV_LOST_TSYNC"));
            break;
        case EV_RESET:
            Serial.println(F("EV_RESET"));
            break;
        case EV_RXCOMPLETE:
            // data received in ping slot
            Serial.println(F("EV_RXCOMPLETE"));
            break;
        case EV_LINK_DEAD:
            Serial.println(F("EV_LINK_DEAD"));
            break;
        case EV_LINK_ALIVE:
            Serial.println(F("EV_LINK_ALIVE"));
            break;
         default:
            Serial.println(F("Unknown event"));
            break;
    }
}

void do_send(osjob_t* j){
    // Check if there is not a current TX/RX job running
    if (LMIC.opmode & OP_TXRXPEND) {
        Serial.println(F("OP_TXRXPEND, not sending"));
    } else {
        // Prepare upstream data transmission at the next possible time.
        // setup distance sound sensor
        digitalWrite(Ptrig, LOW);
        delayMicroseconds(2);
        digitalWrite(Ptrig, HIGH);   // genera el pulso de triger por 10ms
        delayMicroseconds(10);
        digitalWrite(Ptrig, LOW);

        duracion = pulseIn(Pecho, HIGH);
     
        distancia = (duracion/2) / 29;            // calcula la distancia en centimetros
  
        if (distancia >= 500 || distancia <= 0){  // si la distancia es mayor a 500cm o menor a 0cm 
            Serial.println("---");                  // no mide nada
        }
        else {
        Serial.print(distancia);           // envia el valor de la distancia por el puerto serial
        Serial.println("cm");              // le coloca a la distancia los centimetros "cm"
        digitalWrite(13, 0);               // en bajo el pin 13
        digitalWrite(4, 1); 

        
        uint32_t distance=distancia * 10;

        Serial.println("distance: " + String(distance));

        latitude = 4.64580;
        longitude = -74.09183; 

        Serial.println("Latitud/Longitud: " + String(latitude)+" , " + String(longitude));

        int32_t lat = latitude * 100000;
        int32_t lon = longitude * 100000;

        Serial.println("Latitud/Longitud: " + String(lat)+" , " + String(lon));

        byte payload[8];

        payload[0] = lat;
        payload[1] = lat >> 8;
        payload[2] = lat >> 16;
        
        payload[3] = lon;
        payload[4] = lon >> 8;
        payload[5] = lon >> 16;
        
        payload[6] = highByte(distance); 
        payload[7] = lowByte(distance);
        
        LMIC_setTxData2(1, payload, sizeof(payload), 0);
        //LMIC_setTxData2(1, mydata, sizeof(mydata)-1, 0);
        
        Serial.println(F("Packet queued"));
        }
    }
    delay(3000); 
    // Next TX is scheduled after TX_COMPLETE event.
}

void setup() {
    Pecho = 6;           
  Ptrig = 7;
  Serial.begin(9600);      // inicializa el puerto seria a 9600 baudios
  pinMode(Pecho, INPUT);     // define el pin 6 como entrada (echo)
  pinMode(Ptrig, OUTPUT);    // define el pin 7 como salida  (triger)
  pinMode(13, 1);            // Define el pin 13 como salida
  pinMode(4, 1);
    Serial.println(F("Starting"));

    #ifdef VCC_ENABLE
    // For Pinoccio Scout boards
    pinMode(VCC_ENABLE, OUTPUT);
    digitalWrite(VCC_ENABLE, HIGH);
    delay(1000);
    #endif

    // LMIC init
    os_init();
    // Reset the MAC state. Session and pending data transfers will be discarded.
    LMIC_reset();

    // Start job (sending automatically starts OTAA too)
    do_send(&sendjob);
}

void loop() {
    os_runloop_once();
}
