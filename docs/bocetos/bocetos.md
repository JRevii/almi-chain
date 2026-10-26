# Bocetos de la web (diseño conceptual)

**Responsable:** Jose · **Fechas:** 26–27 oct · **Carpeta en el repo:** `docs/bocetos/`

## Objetivo
Definir la estructura y el aspecto de la web antes de programarla, en móvil y en escritorio.

## Secciones (en este orden)
1. Cabecera (`<header>`): logo y menú de navegación.
2. Inicio: imagen de portada, eslogan (`<h1>`) y botón "Ver carta".
3. Platos estrella: slideshow con flechas, puntos y texto alternativo en cada foto.
4. Carta resumida: entrantes, principales y postres.
5. Dónde estamos: mapa con Leaflet y botón de geolocalización.
6. Contacto: formulario de muestra que no envía datos.
7. Pie (`<footer>`): horario, dirección, teléfono y redes.

## Decisiones de diseño
- **Mobile first:** se diseña primero para 375 px y se amplía con `@media (min-width: 1024px)`.
- **Móvil:** una columna; menú plegado en un botón ☰ (`<button aria-expanded>`).
- **Escritorio:** menú horizontal, carta en 3 columnas (CSS Grid), mapa y contacto lado a lado, contenido centrado con un ancho máximo.
- **Accesibilidad:** HTML semántico, `alt` en las imágenes, controles del slideshow usables con teclado y que se paran con el foco o el ratón.
- **Mínimo privilegio y privacidad:** la ubicación se pide solo al pulsar el botón; el formulario no recoge datos.

## Pasos para reproducirlo
1. Abrir Excalidraw (https://excalidraw.com) o similar.
2. Dibujar un marco de 375 px de ancho (móvil) y otro de unos 1024–1280 px (escritorio).
3. Colocar las secciones en el orden de arriba, con rectángulos y cruces para las imágenes.
4. Exportar en PNG y guardar en `docs/bocetos/`.

## Evidencias
- `boceto_movil.png`
- `boceto_escritorio.png`
- `Almi-Chain_bocetos_web.pdf`: las opciones dibujadas.
- `Almi-Chain_bocetos_finalistas.pdf`: las finalistas y la valoración. Ganó **Latón** (8,8 sobre 10).
