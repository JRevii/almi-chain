// Mando arcade con Arduino Leonardo: teclado USB + LED RGB + LED verde + LED rojo + altavoz + botón lateral.
// START (botón lateral) enciende el "modo fiesta": LED RGB con colores en bucle + LED verde fijo.
// Al pulsar START otra vez se apaga todo y el LED rojo se enciende 1 segundo.
// Entradas con INPUT_PULLUP: sin pulsar = HIGH, pulsado = LOW.
#include <Keyboard.h>

// ---- Ajustes ----
const bool ANODO_COMUN = false;      // true si la pata larga del LED RGB va a 5V (+) en vez de a GND (−)
const bool SONIDO = true;            // false para silenciar los pitidos de los botones
const bool ZUMBADOR_ACTIVO = false;  // true si el zumbador pita solo al darle 5V fijos (zumbador activo)

// ---- Entradas ----
const int NUM = 9;
//                         ARRIBA        ABAJO           IZQUIERDA       DERECHA          B1             B2   B3        B4       LATERAL(START)
const int     pines[NUM]  = {3,            4,              5,              2,               9,             8,   7,        6,       A0};
const uint8_t teclas[NUM] = {KEY_UP_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW, KEY_RIGHT_ARROW, KEY_LEFT_CTRL, '5', 'p',      KEY_ESC, '1'};
const int START = 8;  // posición del botón LATERAL en las tablas de arriba (es el START)

// ---- Salidas ----
const int LED_RGB[3] = {10, 11, 12};  // LED de la izquierda: R, G, B
const int LED_VERDE  = 1;             // LED del medio
const int LED_ROJO   = 0;             // LED de la derecha
const int ALTAVOZ    = 13;

const byte ARCOIRIS[7][3] = {{1,0,0}, {1,1,0}, {0,1,0}, {0,1,1}, {0,0,1}, {1,0,1}, {1,1,1}};
const int  TONO_BTN[5]    = {2093, 2637, 2349, 1568, 1760};  // Hz: disparo, moneda, pausa, salir, start
const unsigned long PASO_ARCOIRIS_MS = 150;                  // cada cuánto cambia de color
const unsigned long ROJO_MS = 1000;                          // tiempo del LED rojo al apagar

bool encendido = false;             // ¿está activo el modo fiesta?
unsigned long finRojo = 0;          // momento en que se apaga el LED rojo (0 = apagado)
unsigned long finPitido = 0;

bool pulsado[NUM];
unsigned long ultimoCambio[NUM];
const unsigned long REBOTE_MS = 10;

void ponerColor(byte r, byte g, byte b) {
  byte c[3] = {r, g, b};
  for (int i = 0; i < 3; i++) digitalWrite(LED_RGB[i], (c[i] == 1) != ANODO_COMUN ? HIGH : LOW);
}

// Pitido sin parar el programa: tone() para zumbador pasivo, encender/apagar para uno activo
void pitar(int frecuencia, int ms) {
  if (ZUMBADOR_ACTIVO) { digitalWrite(ALTAVOZ, HIGH); finPitido = millis() + ms; }
  else tone(ALTAVOZ, frecuencia, ms);
}

void setup() {
  for (int i = 0; i < NUM; i++) { pinMode(pines[i], INPUT_PULLUP); pulsado[i] = false; ultimoCambio[i] = 0; }
  for (int i = 0; i < 3; i++) pinMode(LED_RGB[i], OUTPUT);
  pinMode(LED_VERDE, OUTPUT);
  pinMode(LED_ROJO, OUTPUT);
  pinMode(ALTAVOZ, OUTPUT);

  // Arranque: prueba de las 3 luces y melodía (también deja margen para resubir el sketch)
  ponerColor(1,1,1); digitalWrite(LED_VERDE, HIGH); digitalWrite(LED_ROJO, HIGH);
  int melodia[] = {1047, 1319, 1568, 2093};
  for (int n : melodia) { pitar(n, 150); delay(150); digitalWrite(ALTAVOZ, LOW); delay(50); }
  delay(1200);
  ponerColor(0,0,0); digitalWrite(LED_VERDE, LOW); digitalWrite(LED_ROJO, LOW);

  Keyboard.begin();
}

void loop() {
  unsigned long ahora = millis();

  // 1. Leer entradas, enviar teclas y pitar al pulsar un botón
  for (int i = 0; i < NUM; i++) {
    bool lectura = (digitalRead(pines[i]) == LOW);
    if (lectura != pulsado[i] && ahora - ultimoCambio[i] > REBOTE_MS) {
      pulsado[i] = lectura; ultimoCambio[i] = ahora;
      if (lectura) Keyboard.press(teclas[i]); else Keyboard.release(teclas[i]);
      if (lectura && i >= 4 && SONIDO) pitar(TONO_BTN[i - 4], 100);

      // START: encender o apagar el modo fiesta
      if (lectura && i == START) {
        encendido = !encendido;
        finRojo = encendido ? 0 : ahora + ROJO_MS;  // al apagar, rojo durante 1 segundo
      }
    }
  }

  if (ZUMBADOR_ACTIVO && finPitido != 0 && ahora >= finPitido) { digitalWrite(ALTAVOZ, LOW); finPitido = 0; }

  // 2. LED RGB (izquierda): colores en bucle mientras está encendido
  if (encendido) {
    int paso = (ahora / PASO_ARCOIRIS_MS) % 7;
    ponerColor(ARCOIRIS[paso][0], ARCOIRIS[paso][1], ARCOIRIS[paso][2]);
  } else {
    ponerColor(0,0,0);
  }

  // 3. LED verde (medio): fijo mientras está encendido
  digitalWrite(LED_VERDE, encendido ? HIGH : LOW);

  // 4. LED rojo (derecha): 1 segundo después de apagar
  if (finRojo != 0 && ahora < finRojo) digitalWrite(LED_ROJO, HIGH);
  else { digitalWrite(LED_ROJO, LOW); finRojo = 0; }
}
