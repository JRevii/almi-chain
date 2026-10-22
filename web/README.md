# web/ · Página de Almi-Chain (concepto «Latón»)

Web estática **unidireccional**: solo informa. No tiene backend, base de datos ni formularios que envíen datos.

## Estructura

```
web/
├── index.html              Página única con las 9 secciones
├── css/styles.css          Todos los estilos (variables de color al principio)
├── js/main.js              Menú móvil, slideshow, opiniones, formulario de muestra, mapa y geolocalización
├── fonts/                  Cormorant Garamond y Jost (woff2, licencia SIL OFL), servidas desde aquí
├── vendor/leaflet/         Leaflet 1.9.4 (mapa), servido desde aquí (licencia BSD-2)
└── img/                    Imágenes. Ahora son PROVISIONALES (SVG): hay que sustituirlas
```

## Pasos para reproducir

La guía completa (decisiones, pasos, pruebas y explicación del código para la defensa) está en [`docs/web/guia_web.md`](../docs/web/guia_web.md).

### Probarla en local

La geolocalización solo funciona en HTTPS o en `localhost`, así que no basta con abrir el archivo con doble clic:

```bash
cd web
python3 -m http.server 8000
# abrir http://localhost:8000
```

## Sustituir las fotos provisionales

Hay que usar fotos propias o con licencia libre (por ejemplo, de Unsplash o Pexels), anotando la fuente en la documentación. Se recomienda **WebP**, de 150 KB como máximo cada una, con fondo oscuro y luz cálida.

| Archivo actual | Contenido | Proporción |
|---|---|---|
| `img/hero.svg` | Mesa preparada, luz cálida | 4:5 (800×1000) |
| `img/nosotros.svg` | Equipo en la cocina | 3:4 (600×800) |
| `img/plato-1.svg` … `plato-4.svg` | Kokotxas, pichón, txangurro, torrija | 4:5 (800×1000) |
| `img/galeria-1.svg` … `galeria-3.svg` | Sala, detalle de mesa, bodega | 3:4 (600×800) |

Si cambias la extensión (`.svg` → `.webp`), cámbiala también en `index.html`, incluidos los atributos `data-img` de los botones del slideshow. Cambia también el texto `alt` si la foto es distinta.

## Seguridad y mínimo privilegio

- **No recoge datos.** El formulario de reservas es de muestra: el JavaScript cancela el envío y, además, la cabecera CSP tiene `form-action 'none'`, así que el navegador bloquea cualquier envío.
- **Sin claves, tokens ni contraseñas** en el código.
- **Sin dependencias de terceros en tiempo de carga.** Las fuentes y Leaflet se sirven desde nuestro servidor. Lo único externo son las teselas del mapa de OpenStreetMap (permitidas en la CSP).
- **Ubicación.** Solo se pide al pulsar el botón y nunca sale del navegador: la distancia se calcula en el propio JavaScript.
- **CSP** (`<meta http-equiv="Content-Security-Policy">`): solo se permiten scripts, estilos y fuentes de nuestro dominio.

## Para Jon (despliegue en Nginx)

Lighthouse local da 99–100 en las cuatro categorías. Lo único que propone es comprimir y cachear, y eso se configura en el servidor:

```nginx
# dentro del server { listen 443 ssl; ... }
root /var/www/almichain;
index index.html;

gzip on;
gzip_types text/css application/javascript image/svg+xml;

location ~* \.(css|js|woff2|svg|png|webp|jpg)$ {
    expires 30d;
    add_header Cache-Control "public";
}

# Cabeceras de seguridad (la CSP también va en el HTML; en cabecera admite frame-ancestors)
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data: https://tile.openstreetmap.org; font-src 'self'; connect-src 'self'; form-action 'none'; base-uri 'self'; object-src 'none'; frame-ancestors 'none'" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(self), camera=(), microphone=()" always;
add_header Strict-Transport-Security "max-age=31536000" always;
```

## Datos de ejemplo que hay que revisar

Las direcciones (`Calle Ejemplo…`), los teléfonos (`944 000 00X`), los precios, las opiniones y el tipo de cocina (vasca de temporada) son de ejemplo. Las coordenadas del mapa son aproximadas, del centro de cada municipio. Todo está en `index.html`, y las coordenadas en `js/main.js` (constante `LOCALES`).
