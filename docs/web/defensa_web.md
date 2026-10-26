# Defensa de la web: preguntas y respuestas

| Responsable | Fecha | Relacionado |
|---|---|---|
| Jose | 22/10/2026 | `guia_web.md` (explicación completa), `capturas/` |

Respuestas cortas, con mis palabras, para la defensa del reto. Cada una indica dónde está en el código.

## 1. Lo básico

**¿Qué hace cada archivo?**
HTML (`index.html`) es el contenido, CSS (`css/styles.css`) el aspecto y JavaScript (`js/main.js`) el comportamiento: lo que reacciona cuando el usuario hace algo.

**¿Qué significa que la web sea unidireccional?**
Que solo informa: no recoge datos de los clientes. Por eso no tiene base de datos, ni usuarios, ni un formulario que envíe nada.

**¿Java y JavaScript son lo mismo?**
No, son lenguajes distintos. La web usa JavaScript.

**¿Cómo se prueba en local?**
Con la extensión Live Server de VS Code (clic derecho en `index.html` → *Open with Live Server*). Si VS Code abre la carpeta en *Modo restringido*, hay que pulsar *Trust*: VS Code desactiva las extensiones hasta que confías en la carpeta, igual que el mínimo privilegio.

## 2. Responsive (CSS)

**¿Qué es el diseño responsive?**
La misma web se adapta al tamaño de la pantalla, sin hacer dos versiones. En el móvil el menú se convierte en un botón ☰ y todo pasa a una columna. En el ordenador, la carta sale en 3 columnas.

**¿Qué es una media query?** (`styles.css`, línea 284)
Una regla de CSS que solo se aplica si la pantalla cumple una condición. `@media (max-width: 900px) { … }` significa "si la pantalla mide 900 px o menos, aplica estas reglas". Dentro van selectores normales con `class`. Así ocultamos el menú (`.nav { display: none; }`) y mostramos el botón ☰ en el móvil.

**¿Qué es el punto de corte (breakpoint)?**
El número de la media query (900 px): a partir de ese ancho la web pasa a modo móvil.

**`max-width` sale dos veces, ¿es lo mismo?**
No.
- Como propiedad, `.wrap { max-width: 1200px; }`, dice que esa caja mide como mucho 1200 px.
- Dentro de `@media (max-width: 900px)` es una condición sobre el ancho de la pantalla.

Truco: si va detrás de `@media`, habla de la pantalla.

**¿Por qué la web está centrada en una pantalla grande?** (`styles.css`, línea 69)
Por `.wrap { max-width: 1200px; margin: 0 auto; }`. El contenido mide como mucho 1200 px y el espacio que sobra se reparte a los dos lados. Si las líneas de texto ocupan toda una pantalla de 1920 px, cuestan de leer.

## 3. HTML y CSS juntos

**¿Cómo se conectan el HTML y el CSS?**
Con `class`. Al añadir un plato a la carta copiando `class="dish"`, `class="dots"` y `class="price"`, sale con los puntitos y el precio dorado sin tocar el CSS, porque el CSS ya tiene reglas para esas clases. Así se separa el contenido del diseño.

**Lección aprendida:** cada etiqueta que se abre hay que cerrarla en su sitio. Un `</div>` de más o fuera de lugar descoloca toda la carta.

**¿Cómo está hecha cada línea de la carta?** (`styles.css`, líneas 194–198)
Con flexbox:
- `.dish { display: flex; align-items: baseline; gap: 8px; }` pone el nombre, los puntitos y el precio en fila, alineados por la base del texto.
- `.dots { flex: 1; }` hace que los puntitos ocupen el hueco que sobra, así que el precio siempre queda pegado a la derecha.

**¿Para qué sirven las variables de CSS?** (`styles.css`, líneas 34–44)
Los colores se guardan una sola vez al principio (`--ac: #C9A46A;` es el dorado) y se usan con `var(--ac)`. El dorado se usa 16 veces: si el restaurante cambia de color de marca, se cambia una línea y cambia en toda la web.

## 4. JavaScript

**¿Para qué sirve el JavaScript en esta web?**
Para lo que pasa cuando el usuario hace algo o que cambia con el tiempo:
- abrir el menú ☰
- cambiar de plato en el carrusel, que además rota solo cada 6 s (`INTERVAL = 6000`, en milisegundos)
- buscar el restaurante más cercano con la ubicación
- impedir que el formulario envíe datos

Un enlace normal (`href="#carta"`) no necesita JavaScript.

**Si añado un plato al carrusel, ¿hay que tocar el JavaScript?** (`main.js`, línea 77)
No. `querySelectorAll('.dish-btn')` busca todos los elementos con esa clase, así que el plato nuevo entra solo, haya 4 o 10.

**Lo honesto:** el JavaScript lo hice con ayuda de IA, que el tutor permite. Sé qué hace cada parte y puedo cambiar sus datos.

## 5. Accesibilidad y seguridad

**¿Por qué el carrusel tiene botón Pausar?**
Por accesibilidad: la norma WCAG (2.2.2) dice que si algo se mueve solo durante más de 5 segundos, el usuario tiene que poder pararlo. Alguien que lee despacio o que usa un lector de pantalla no llegaría a leer el plato. Además, se para solo al pasar el ratón por encima.

**¿El formulario de reservas envía datos?**
No. La web es unidireccional y el formulario es de muestra. Está bloqueado dos veces: el JavaScript cancela el envío, y la CSP (`form-action 'none'`) hace que el navegador no deje enviarlo. Así no guardamos datos personales. Para reservar, el cliente llama por teléfono.

**¿Qué es la CSP?**
Una regla de seguridad en el `<head>` que dice desde dónde se puede cargar cada cosa. La nuestra solo permite CSS, JS e imágenes de nuestro propio dominio (`'self'`). Si alguien consiguiera meter un script de otra web, el navegador lo bloquearía.

## 6. Validación W3C

**¿Está validado el HTML?**
Sí, con el validador del W3C (https://validator.w3.org/nu/, *file upload*): **0 errores**. Captura: `capturas/w3c_validacion.png`.

**¿Y los 8 avisos amarillos?**
Son de la CSP, no son errores. Salen porque el archivo se subió suelto, sin servidor, y entonces no tiene dominio: la regla "solo de nuestro dominio" no coincide con nada. En el servidor real todo viene del mismo dominio y se carga bien (con Live Server la web se ve perfecta). Al validar la URL publicada, los avisos desaparecen.

## Capturas para la documentación

| Captura | Qué demuestra |
|---|---|
| `capturas/web_01_escritorio_completa.png` | La web en el ordenador |
| `capturas/web_02_movil_completa.png` | La web en el móvil (responsive) |
| `capturas/web_03_menu_movil.png` | El menú ☰ abierto |
| `capturas/w3c_validacion.png` | Validación W3C: 0 errores |
| `evidencias/lighthouse_local_movil.html` y `lighthouse_local_escritorio.html` | Lighthouse 99–100 |
