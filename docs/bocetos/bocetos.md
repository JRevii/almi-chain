# Bocetos de la web (diseño conceptual)

**Responsable:** Jose · **Fechas:** 26–27 oct · **Carpeta en el repo:** `docs/bocetos/`

## Objetivo
Definir la estructura y el aspecto de la web antes de programarla, en móvil, tablet y escritorio.

## Secciones (en este orden)
1. Cabecera (`<header>`): logo y menú de navegación.
2. Inicio: imagen de portada, eslogan (`<h1>`) y botón "Ver carta".
3. Platos estrella: slideshow con flechas, puntos y texto alternativo en cada foto.
4. Carta resumida: entrantes, principales y postres.
5. Dónde estamos: mapa con Leaflet y botón de geolocalización.
6. Contacto: formulario de muestra que no envía datos.
7. Pie (`<footer>`): horario, dirección, teléfono y redes.

## Decisiones de diseño
- **Pensado primero para el móvil:** la mayoría de los clientes buscan dónde comer desde el móvil, así que se dibujó primero a 375 px y luego se amplió.
- **Tres tamaños**, con dos cortes en el CSS (`@media`):

| Tamaño | Ancho | Cómo se ve | Boceto |
|---|---|---|---|
| Móvil | hasta 600 px | Una columna. Menú plegado en un botón ☰ (`<button aria-expanded>`). La galería se desliza con el dedo | `boceto_movil.png` |
| Tablet | de 601 a 900 px | Sigue el menú ☰, pero se aprovecha el ancho: carta en 3 columnas, locales en 2, fotos centradas sin ocupar toda la pantalla y botones uno al lado del otro | `boceto_tablet.png` |
| Escritorio | más de 900 px | Menú horizontal, carta en 3 columnas (CSS Grid), mapa y locales lado a lado y contenido centrado con un ancho máximo | `boceto_escritorio.png` |

- **Accesibilidad:** HTML semántico, `alt` en las imágenes, controles del slideshow usables con teclado y que se paran con el foco o el ratón.
- **Mínimo privilegio y privacidad:** la ubicación se pide solo al pulsar el botón; el formulario no recoge datos.

## Por qué el diseño es usable

Para justificarlo usamos cuatro de las **10 heurísticas de usabilidad de Jakob Nielsen** (reglas generales para que una web sea fácil de usar) y el contraste de la WCAG.

| Criterio | Qué dice | Cómo lo cumple el diseño |
|---|---|---|
| **Visibilidad del estado del sistema** (Nielsen 1) | El usuario siempre sabe dónde está y qué está pasando | El menú se queda fijo arriba al bajar por la página. En el slideshow, el plato que se ve está marcado en la lista y el botón cambia entre *Pausar* y *Reanudar* |
| **Control y libertad del usuario** (Nielsen 3) | El usuario puede deshacer o salir fácilmente | El slideshow se puede parar. El menú del móvil se cierra con la ✕, con la tecla Esc o tocando fuera. La ubicación solo se pide si el cliente pulsa el botón |
| **Consistencia y estándares** (Nielsen 4) | Lo mismo se ve y funciona igual en toda la web | Todos los botones tienen la misma forma y color (latón), los títulos de sección siguen el mismo patrón y el ☰ es el icono de menú que todo el mundo conoce |
| **Diseño estético y minimalista** (Nielsen 8) | Mostrar solo lo necesario | Una sola acción principal en la portada (*Reservar mesa*) y cada sección con un único título y un único objetivo. Fondo negro sin adornos para que destaquen las fotos de los platos |
| **Botones fáciles de pulsar** | En el móvil, los botones deben medir al menos 44 × 44 px (WCAG 2.5.5) | Botones de 48 px de alto, iconos del pie de 44 × 44 px y el *Reservar mesa* a todo el ancho en el móvil |
| **Contraste** | WCAG AA pide 4,5:1 para el texto | Latón sobre negro: **8,5:1**. Texto principal: 16,2:1. Texto secundario: 7,4:1 |

Fuentes: Nielsen Norman Group, *10 Usability Heuristics for User Interface Design* (https://www.nngroup.com/articles/ten-usability-heuristics/) y WCAG 2.1 (https://www.w3.org/TR/WCAG21/).

## Pasos para reproducirlo
1. Abrir Excalidraw (https://excalidraw.com) o similar.
2. Dibujar un marco de 375 px de ancho (móvil), otro de 768 px (tablet) y otro de unos 1024–1280 px (escritorio).
3. Colocar las secciones en el orden de arriba, con rectángulos y cruces para las imágenes.
4. Exportar en PNG y guardar en `docs/bocetos/`.

## Evidencias
- `boceto_movil.png`
- `boceto_tablet.png` (y su `boceto_tablet.svg`, editable)
- `boceto_escritorio.png`
- `Almi-Chain_bocetos_web.pdf`: las opciones dibujadas.
- `Almi-Chain_bocetos_finalistas.pdf`: las finalistas y la valoración. Ganó **Latón** (8,8 sobre 10).
