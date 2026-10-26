// Mando arcade con Arduino Leonardo: se conecta al PC como TECLADO USB.
// Cableado (ver ../img/montaje_desde_arriba.png): cada entrada va a su pin y a GND.
// INPUT_PULLUP: sin pulsar = HIGH, pulsado = LOW. No se usa 5V.
#include <Keyboard.h>

const int NUM = 8;
// Pin del Leonardo           ARRIBA        ABAJO          IZQUIERDA      DERECHA         B1   B2   B3   B4
const int  pines[NUM]  = {    3,            4,             5,             2,              9,   8,   7,   6  };
const uint8_t teclas[NUM] = { KEY_UP_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW, KEY_RIGHT_ARROW, 'z', 'x', 'c', 'v' };

bool pulsado[NUM];               // estado enviado al PC
unsigned long ultimoCambio[NUM]; // para el antirrebote
const unsigned long REBOTE_MS = 10;

void setup() {
  for (int i = 0; i < NUM; i++) {
    pinMode(pines[i], INPUT_PULLUP);
    pulsado[i] = false;
    ultimoCambio[i] = 0;
  }
  delay(2000);                   // margen para poder resubir el sketch si algo va mal
  Keyboard.begin();
}

void loop() {
  unsigned long ahora = millis();
  for (int i = 0; i < NUM; i++) {
    bool lectura = (digitalRead(pines[i]) == LOW);
    if (lectura != pulsado[i] && ahora - ultimoCambio[i] > REBOTE_MS) {
      pulsado[i] = lectura;
      ultimoCambio[i] = ahora;
      if (lectura) Keyboard.press(teclas[i]);
      else         Keyboard.release(teclas[i]);
    }
  }
}
