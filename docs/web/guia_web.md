# Página web de Almi-Chain

| Responsable | Fechas (Gantt) | Carpeta en el repo | Despliegue |
|---|---|---|---|
| Jose | 28/10 – 04/11 | `web/` · `docs/` | Jon (AWS, Nginx, HTTPS) |

## 1. Objetivo

El enunciado pide una web **unidireccional** (solo informa), **atractiva y responsiva**, con **geolocalización**, un **formulario de contacto de muestra** y un **slideshow de platos estrella**, alojada en la nube. Además, el equipo se marcó como objetivo que fuera accesible y tuviera buen rendimiento (Lighthouse).

**Resultado:** una página única (`web/index.html`) con 9 secciones, una hoja de estilos y un archivo JavaScript, sin frameworks.

## 2. Requisitos previos

- Un editor (VS Code) y un navegador moderno.
- Python 3, para probarla en local con `python3 -m http.server`.
- El boceto elegido: concepto **Latón** (ver los bocetos en el Drive del equipo).

## 3. Decisiones y justificación

| Decisión | Por qué |
|---|---|
| HTML, CSS y JS "a mano", sin frameworks | Es una web pequeña. Así carga rápido y el equipo puede explicar cada línea, que es lo que se evalúa |
| Una sola página con anclas (`#carta`, `#reservas`…) | Toda la información cabe en una página y la navegación es inmediata |
| Diseño *mobile first* y CSS Grid | Primero el móvil (la mayoría de los clientes buscan desde el móvil); con una *media query* a 900 px se pasa a varias columnas |
| Paleta negro + latón | Transmite calidad; el latón sobre negro tiene 8,5:1 de contraste (WCAG AA pide 4,5:1) |
| Fuentes Cormorant Garamond + Jost **servidas desde nuestro servidor** | Si se cargaran desde Google, el navegador del cliente enviaría su IP a Google (RGPD). Así además carga más rápido |
| Leaflet + OpenStreetMap para el mapa | Gratis, sin clave de API y de código abierto. Google Maps pide una clave de API y tarjeta de crédito |
| Leaflet se carga **solo cuando el mapa va a verse** | No retrasa la carga inicial (mejor rendimiento) |
| Formulario de reservas **de muestra** | La web es unidireccional: no puede recoger datos |

## 4. Pasos para reproducirlo

1. **Crear la estructura de carpetas** `web/css`, `web/js`, `web/img`, `web/fonts` y `web/vendor/leaflet`.
   *Por qué:* separar contenido (HTML), presentación (CSS) y comportamiento (JS) facilita el mantenimiento.
2. **Descargar las fuentes** en woff2 desde Google Fonts (por ejemplo, con *google-webfonts-helper*) y guardarlas en `web/fonts/`. En el CSS se declaran con `@font-face` y `font-display: swap`, para que el texto se vea mientras carga la fuente.
3. **Descargar Leaflet 1.9.4** (`npm pack leaflet@1.9.4`, o desde leafletjs.com) y copiar `leaflet.js`, `leaflet.css` e `images/` a `web/vendor/leaflet/`.
4. **Escribir `index.html`** con las etiquetas semánticas: `header`, `nav`, `main`, `section` (una por apartado) y `footer`.
5. **Escribir `css/styles.css`**: primero las variables de color (`:root`), después la base y luego cada sección. Al final, la *media query* para móvil y la de `prefers-reduced-motion`.
6. **Escribir `js/main.js`**: menú móvil, slideshow, opiniones, formulario de muestra, mapa con geolocalización y animaciones.
7. **Probar en local:** `cd web && python3 -m http.server 8000` y abrir `http://localhost:8000`. La geolocalización funciona en `localhost` porque el navegador lo trata como contexto seguro.
   📸 *Captura:* `capturas/web_01_escritorio_completa.png` y `web_02_movil_completa.png`.
8. **Validar el HTML.** Pasar `index.html` por el validador del W3C (https://validator.w3.org/nu/, opción "File upload").
   📸 *Captura:* resultado "Document checking completed. No errors or warnings to show."
9. **Pasar Lighthouse** (Chrome → F12 → Lighthouse), en móvil y en escritorio.
   📸 *Captura:* las cuatro puntuaciones.
10. **Subir a GitHub** la carpeta `web/` y esta guía en `docs/`. Jon la despliega en la EC2 con Nginx y HTTPS.

## 5. Seguridad y mínimo privilegio

- **No se recoge ningún dato.** `form-action 'none'` en la CSP bloquea cualquier envío de formulario, y además el JS cancela el `submit`.
- **Política de seguridad de contenidos (CSP):** solo se ejecutan scripts y se cargan estilos y fuentes de nuestro dominio. Si alguien inyectara un script de otro sitio, el navegador lo bloquearía.
- **Ninguna clave, token ni contraseña** en el código. Por eso se eligió OpenStreetMap: no necesita clave de API.
- **Ubicación con permiso explícito.** Solo se pide al pulsar el botón, y la distancia se calcula en el navegador; la posición no se envía a ningún sitio.
- **Cabeceras de seguridad en Nginx** (las configura Jon; vienen en `web/README.md`).

## 6. Pruebas y evidencias

| Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|
| La web se ve bien a 1440 px y a 390 px | Sin desbordes ni texto cortado | ✅ | `capturas/web_01…`, `web_02…` |
| Menú móvil: abrir, Tab, Esc | Se abre, el foco queda dentro y se cierra con Esc | ✅ | `capturas/web_03_menu_movil.png` |
| Slideshow: clic, flechas ↑↓ y Pausar | Cambia el plato y la foto; se puede parar | ✅ | — (hacer vídeo corto) |
| Formulario de muestra | No envía nada y muestra el aviso | ✅ | — |
| Geolocalización (simulada en Getxo) | "El más cercano es Getxo, a unos 3,1 km" | ✅ | — |
| Validación del HTML | 0 errores | ✅ 0 errores con html-validate; ⏳ pendiente la captura del validador del W3C | — |
| Lighthouse en local (móvil) | ≥ 90 | ✅ Rendimiento 99 · Accesibilidad 100 · Buenas prácticas 100 · SEO 100 | `evidencias/lighthouse_local_movil.html` |
| Lighthouse en local (escritorio) | ≥ 90 | ✅ 100 · 100 · 100 · 100 | `evidencias/lighthouse_local_escritorio.html` |
| Lighthouse de la web publicada (con Jon) | ≥ 90 | ⏳ 9–10 nov | — |
| Web publicada en AWS: carga por `https://almichain.duckdns.org` con las fotos reales | Candado y página completa, sin imágenes provisionales | ✅ 22/10 | `capturas/aws_01_portada_https.png`, `aws_02_nosotros.png`, `aws_03_platos_slideshow.png` |
| Web publicada: formulario de muestra | Muestra el aviso y no envía nada | ✅ 22/10 | `capturas/aws_04_reservas_formulario_muestra.png` |
| Web publicada: mapa con los 4 locales | Aparecen los 4 marcadores sobre OpenStreetMap | ✅ 22/10 | `capturas/aws_05_mapa_locales.png` |

*Nota:* las pruebas en local se hicieron con fotos provisionales en SVG. Con las fotos reales hay que repetir Lighthouse: si las fotos pesan mucho, el rendimiento baja (de ahí la recomendación de WebP de menos de 150 KB).

## 7. Explicación del código (para la defensa)

### HTML: estructura semántica
- `<header>`, `<nav>`, `<main>`, `<section>` y `<footer>` le dicen al navegador y a los lectores de pantalla qué es cada parte. Cada `section` tiene `aria-labelledby` apuntando a su título.
- **"Saltar al contenido"** (`<a class="skip" href="#main">`): es el primer enlace, oculto hasta que recibe el foco. Permite a quien navega con teclado saltarse el menú.
- **Imágenes** con `width` y `height` (así el navegador reserva el hueco y la página no "salta" al cargar), con `alt` descriptivo y con `loading="lazy"` en todas menos la principal, que lleva `fetchpriority="high"`.
- **Botones de verdad** (`<button>`) para todo lo que hace algo, y enlaces (`<a href>`) para lo que lleva a otro sitio. Así funcionan con teclado sin código extra.

### CSS
- **Variables** (`--bg`, `--ac`…): toda la paleta en un sitio. Cambiar el color de la marca es cambiar una línea.
- **`clamp()`** en los tamaños de letra: `clamp(2.75rem, 5.5vw, 5rem)` significa "como mínimo 2,75 rem, como máximo 5 rem, y entre medias el 5,5 % del ancho de la pantalla". El texto se adapta sin necesidad de *media queries*.
- **El arco** es `border-radius: 999px 999px 0 0` (esquinas superiores totalmente redondas). **El marco interior** es `outline: 1px solid; outline-offset: -12px` (un borde dibujado 12 px hacia dentro). No hacen falta imágenes extra.
- **Responsive:** por debajo de 900 px las rejillas pasan a una columna, el menú se convierte en botón y la galería se desliza en horizontal (`scroll-snap`).
- **`prefers-reduced-motion`:** si el sistema del usuario pide menos movimiento, se quitan las animaciones y el slideshow no avanza solo.
- **Mapa oscuro** con `filter: invert(1) hue-rotate(180deg)` sobre las teselas: invierte los colores y recoloca los tonos para que el mapa sea oscuro sin contratar otro servicio.

### JavaScript
- **Menú móvil:** al abrirlo cambia `aria-expanded` a `true` (el lector de pantalla anuncia "expandido") y el foco entra en el menú. Se cierra con Esc, con la X o con el fondo, y el foco vuelve al botón. Con Tab, el foco no se escapa del cajón ("trampa de foco").
- **Slideshow:** cada plato es un `<button>` de una lista ordenada. Al pulsarlo se marca con `aria-current="true"` y la foto cambia con un fundido. Avanza solo cada 6 s, pero se para al pasar el ratón o el foco, y tiene botón **Pausar** (WCAG 2.2.2 exige poder parar lo que se mueve solo más de 5 s).
- **Formulario de muestra:** `e.preventDefault()` cancela el envío y se muestra un aviso en una zona `role="status"`, que el lector de pantalla lee.
- **Mapa:** un `IntersectionObserver` detecta cuándo el mapa está cerca de verse y solo entonces carga Leaflet.
- **Geolocalización:** `navigator.geolocation.getCurrentPosition()` pide la posición (el navegador muestra el permiso). Con la **fórmula de Haversine** se calcula la distancia en km a cada local y nos quedamos con la menor (`reduce`). Se tratan los errores: permiso denegado, sin señal o tiempo agotado. `window.isSecureContext` comprueba que estamos en HTTPS, porque si no la API no funciona.

### Preguntas que puede hacer el profesor
- **¿Por qué la geolocalización necesita HTTPS?** Porque la ubicación es un dato sensible; los navegadores solo la permiten en contextos seguros, para que nadie pueda interceptarla.
- **¿Cómo garantizas que la web no recoge datos?** El formulario no tiene `action`, el JS cancela el envío y la CSP con `form-action 'none'` lo bloquea aunque se quitara el JS.
- **¿Qué es la CSP?** Una lista blanca, enviada al navegador, de los orígenes desde los que puede cargar cada tipo de recurso. Protege contra la inyección de scripts (XSS).
- **¿Por qué no Bootstrap o WordPress?** Para una web de una página añadiría peso y superficie de ataque (WordPress necesita PHP y una base de datos) sin aportar nada. Con HTML estático, el servidor solo entrega archivos.
- **¿Cómo se comprobó la accesibilidad?** Con el contraste calculado con la fórmula de la WCAG, Lighthouse (100) y probando la página solo con teclado.

## 8. Problemas encontrados y solución

- **Leaflet usa una imagen `data:` para las teselas vacías**, que la CSP bloqueaba. Solución: añadir `data:` a `img-src`, solo para imágenes.
- **Fondo gris del mapa antes de cargar las teselas.** El selector era `.map .leaflet-container`, pero la clase está en el propio `#map`. Solución: `.map.leaflet-container`.

## 9. Fuentes

- WCAG 2.1, contraste y 2.2.2 "Pausar, detener, ocultar": https://www.w3.org/TR/WCAG21/ (consultado el 22/10/2026)
- Documentación de Leaflet: https://leafletjs.com/reference.html
- API de geolocalización (MDN): https://developer.mozilla.org/es/docs/Web/API/Geolocation_API
- Content Security Policy (MDN): https://developer.mozilla.org/es/docs/Web/HTTP/CSP
- Licencias: Cormorant Garamond y Jost (SIL Open Font License), Leaflet (BSD-2), teselas © colaboradores de OpenStreetMap (ODbL)
