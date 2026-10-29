// Mando arcade con Arduino Leonardo: se conecta al PC como TECLADO USB.
// Cableado (ver ../img/montaje_desde_arriba.png): cada entrada va a su pin y a GND.
// INPUT_PULLUP: sin pulsar = HIGH, pulsado = LOW. No se usa 5V.
//
// Controles (teclas por defecto de MAME, sin configurar nada):
//   Joystick  -> flechas (las diagonales funcionan: se mantienen dos flechas a la vez)
//   B1, B2    -> botones de acción 1 y 2 de MAME (Ctrl izquierdo y Alt izquierdo)
//   B3        -> MONEDA (tecla 5)
//   B4        -> START  (tecla 1)
//   Mantener B4 (START) 2 segundos -> ESC: salir del juego al menú de MAME
#include <Keyboard.h>

const int NUM = 8;
// Pin del Leonardo           ARRIBA        ABAJO           IZQUIERDA       DERECHA          B1              B2             B3    B4
const int  pines[NUM]  = {    3,            4,              5,              2,               9,              8,             7,    6   };
const uint8_t teclas[NUM] = { KEY_UP_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW, KEY_RIGHT_ARROW, KEY_LEFT_CTRL, KEY_LEFT_ALT, '5',  '1' };

const int START = 7;                     // posición de B4 en las tablas
const unsigned long REBOTE_MS = 10;      // antirrebote
const unsigned long SALIR_MS  = 2000;    // tiempo manteniendo START para enviar ESC

bool pulsado[NUM];               // estado enviado al PC
unsigned long ultimoCambio[NUM]; // para el antirrebote
unsigned long inicioStart = 0;   // cuándo se pulsó START
bool escEnviado = false;         // para enviar ESC una sola vez por pulsación

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
      if (lectura) {
        Keyboard.press(teclas[i]);
        if (i == START) { inicioStart = ahora; escEnviado = false; }
      } else {
        Keyboard.release(teclas[i]);
      }
    }
  }

  // START mantenido 2 s: suelta el 1 y pulsa ESC una vez
  if (pulsado[START] && !escEnviado && ahora - inicioStart >= SALIR_MS) {
    Keyboard.release(teclas[START]);
    Keyboard.press(KEY_ESC);
    delay(50);
    Keyboard.release(KEY_ESC);
    escEnviado = true;
  }
}
