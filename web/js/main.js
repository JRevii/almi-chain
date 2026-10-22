/* =========================================================
   Almi-Chain · JavaScript de la web
   Sin librerías salvo Leaflet (mapa), que se carga solo
   cuando el mapa está a punto de verse.
   Partes: 1. Menú móvil  2. Slideshow de platos  3. Opiniones
           4. Formulario de muestra  5. Mapa y geolocalización
           6. Animación al hacer scroll  7. Año del pie
   ========================================================= */
'use strict';

// Si el JS funciona, quitamos la clase no-js (sin JS todo se ve igual, sin animaciones).
document.documentElement.classList.remove('no-js');

// ¿El usuario pide menos movimiento en su sistema?
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

document.addEventListener('DOMContentLoaded', () => {
  initMenu();
  initSlideshow();
  initQuotes();
  initSampleForm();
  initMap();
  initReveal();
  const year = document.querySelector('[data-year]');
  if (year) year.textContent = new Date().getFullYear();
});

/* 1. MENÚ MÓVIL (cajón lateral) ---------------------------------- */
function initMenu() {
  const openBtn = document.querySelector('.menu-btn');
  const drawer = document.getElementById('drawer');
  const backdrop = document.querySelector('.drawer-backdrop');
  const closeBtn = drawer.querySelector('.drawer__close');
  if (!openBtn || !drawer) return;

  function open() {
    drawer.hidden = false;
    backdrop.hidden = false;
    // Esperamos un fotograma para que la transición se vea
    requestAnimationFrame(() => drawer.classList.add('is-open'));
    openBtn.setAttribute('aria-expanded', 'true');
    drawer.querySelector('a').focus();           // el foco entra en el menú
    document.addEventListener('keydown', onKey);
  }

  function close() {
    drawer.classList.remove('is-open');
    openBtn.setAttribute('aria-expanded', 'false');
    document.removeEventListener('keydown', onKey);
    const hide = () => { drawer.hidden = true; backdrop.hidden = true; };
    if (reduceMotion) hide(); else setTimeout(hide, 300);
    openBtn.focus();                              // el foco vuelve al botón
  }

  function onKey(e) {
    if (e.key === 'Escape') close();
    // Mantener el foco dentro del cajón mientras está abierto
    if (e.key === 'Tab') {
      const items = drawer.querySelectorAll('a, button');
      const first = items[0];
      const last = items[items.length - 1];
      if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
    }
  }

  openBtn.addEventListener('click', open);
  closeBtn.addEventListener('click', close);
  backdrop.addEventListener('click', close);
  drawer.querySelectorAll('ul a').forEach((a) => a.addEventListener('click', close));
}

/* 2. SLIDESHOW DE PLATOS ESTRELLA -------------------------------- */
function initSlideshow() {
  const root = document.querySelector('[data-slideshow]');
  if (!root) return;
  const buttons = [...root.querySelectorAll('.dish-btn')];
  const img = root.querySelector('.slideshow__figure img');
  const status = root.querySelector('[data-status]');
  const toggle = root.querySelector('[data-toggle]');
  const INTERVAL = 6000;          // 6 s por plato
  let current = 0;
  let timer = null;
  let pausedByUser = reduceMotion; // con movimiento reducido no avanza solo

  function show(index, announce) {
    current = (index + buttons.length) % buttons.length;
    buttons.forEach((b, i) => b.setAttribute('aria-current', i === current ? 'true' : 'false'));
    const btn = buttons[current];
    // Fundido: ocultar, cambiar la foto y volver a mostrar
    img.classList.add('is-fading');
    setTimeout(() => {
      img.src = btn.dataset.img;
      img.alt = btn.dataset.alt;
      img.classList.remove('is-fading');
    }, reduceMotion ? 0 : 200);
    // Solo anunciamos al lector de pantalla los cambios que pide el usuario
    if (announce) {
      status.textContent = `Plato ${current + 1} de ${buttons.length}: ${btn.querySelector('.dish__name').textContent}`;
    }
  }

  function start() {
    stop();
    if (!pausedByUser) timer = setInterval(() => show(current + 1, false), INTERVAL);
  }
  function stop() { clearInterval(timer); timer = null; }

  buttons.forEach((b, i) => {
    b.addEventListener('click', () => { show(i, true); start(); });
    // Flechas arriba/abajo para moverse por la lista con teclado
    b.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
        e.preventDefault();
        const next = (i + (e.key === 'ArrowDown' ? 1 : -1) + buttons.length) % buttons.length;
        buttons[next].focus();
        show(next, true);
      }
    });
  });
  root.querySelector('[data-prev]').addEventListener('click', () => { show(current - 1, true); start(); });
  root.querySelector('[data-next]').addEventListener('click', () => { show(current + 1, true); start(); });

  // Botón Pausar/Reanudar (WCAG 2.2.2: todo lo que se mueve solo se puede parar)
  function updateToggle() {
    toggle.textContent = pausedByUser ? 'Reanudar' : 'Pausar';
    toggle.setAttribute('aria-pressed', String(pausedByUser));
  }
  toggle.addEventListener('click', () => { pausedByUser = !pausedByUser; updateToggle(); start(); });
  updateToggle();

  // Pausa automática mientras el ratón o el foco están dentro
  root.addEventListener('mouseenter', stop);
  root.addEventListener('mouseleave', start);
  root.addEventListener('focusin', stop);
  root.addEventListener('focusout', start);

  start();
}

/* 3. OPINIONES (una cita cada vez) ------------------------------- */
function initQuotes() {
  const root = document.querySelector('[data-quotes]');
  if (!root) return;
  const quotes = [...root.querySelectorAll('.quote')];
  const dots = [...root.querySelectorAll('.quotes__dots button')];
  dots.forEach((dot, i) => dot.addEventListener('click', () => {
    quotes.forEach((q, j) => { q.hidden = j !== i; });
    dots.forEach((d, j) => d.setAttribute('aria-current', j === i ? 'true' : 'false'));
  }));
}

/* 4. FORMULARIO DE MUESTRA (no envía nada) ------------------------ */
function initSampleForm() {
  const form = document.querySelector('[data-sample-form]');
  if (!form) return;
  const status = form.querySelector('[data-form-status]');
  form.addEventListener('submit', (e) => {
    e.preventDefault();   // nunca se envía: la web es unidireccional
    status.textContent = 'Formulario de muestra: no se ha enviado ningún dato. Para reservar, llama al 944 000 000.';
  });
}

/* 5. MAPA (Leaflet) Y GEOLOCALIZACIÓN ---------------------------- */
// Locales de la cadena (direcciones de ejemplo; coordenadas aproximadas de cada municipio)
const LOCALES = [
  { id: 'bilbao',    nombre: 'Bilbao Centro', lat: 43.2630, lon: -2.9350 },
  { id: 'getxo',     nombre: 'Getxo',         lat: 43.3569, lon: -3.0110 },
  { id: 'barakaldo', nombre: 'Barakaldo',     lat: 43.2967, lon: -2.9886 },
  { id: 'durango',   nombre: 'Durango',       lat: 43.1706, lon: -2.6336 }
];

let map = null;
let markers = {};

function initMap() {
  const mapEl = document.getElementById('map');
  if (!mapEl) return;

  // Cargamos Leaflet solo cuando el mapa va a aparecer (mejor rendimiento)
  const io = new IntersectionObserver((entries) => {
    if (entries.some((e) => e.isIntersecting)) {
      io.disconnect();
      loadLeaflet().then(() => drawMap(mapEl)).catch(() => {
        mapEl.querySelector('.map__fallback').textContent = 'No se ha podido cargar el mapa.';
      });
    }
  }, { rootMargin: '300px' });
  io.observe(mapEl);

  document.querySelector('[data-geo]').addEventListener('click', findNearest);
}

function loadLeaflet() {
  return new Promise((resolve, reject) => {
    const css = document.createElement('link');
    css.rel = 'stylesheet';
    css.href = 'vendor/leaflet/leaflet.css';
    document.head.appendChild(css);
    const js = document.createElement('script');
    js.src = 'vendor/leaflet/leaflet.js';
    js.onload = resolve;
    js.onerror = reject;
    document.head.appendChild(js);
  });
}

function drawMap(mapEl) {
  mapEl.querySelector('.map__fallback').remove();
  map = L.map(mapEl, { scrollWheelZoom: false }).setView([43.27, -2.88], 10);
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);
  LOCALES.forEach((l) => {
    markers[l.id] = L.marker([l.lat, l.lon], { title: l.nombre, alt: `Local ${l.nombre}` })
      .addTo(map)
      .bindPopup(`<strong>${l.nombre}</strong>`);
  });
}

// Distancia en km entre dos puntos (fórmula de Haversine)
function distanciaKm(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const rad = (g) => g * Math.PI / 180;
  const dLat = rad(lat2 - lat1);
  const dLon = rad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

function findNearest() {
  const status = document.querySelector('[data-geo-status]');
  // La API de geolocalización solo funciona en HTTPS (contexto seguro)
  if (!window.isSecureContext || !('geolocation' in navigator)) {
    status.textContent = 'Tu navegador no permite la ubicación en esta página (hace falta HTTPS).';
    return;
  }
  status.textContent = 'Buscando tu ubicación…';
  navigator.geolocation.getCurrentPosition((pos) => {
    const { latitude, longitude } = pos.coords;
    // Calculamos la distancia a cada local y nos quedamos con la menor
    const conDistancia = LOCALES.map((l) => ({ ...l, km: distanciaKm(latitude, longitude, l.lat, l.lon) }));
    const cercano = conDistancia.reduce((a, b) => (b.km < a.km ? b : a));
    document.querySelectorAll('[data-locales] li').forEach((li) => {
      li.classList.toggle('is-nearest', li.dataset.id === cercano.id);
    });
    status.textContent = `El más cercano es ${cercano.nombre}, a unos ${cercano.km.toFixed(1).replace('.', ',')} km.`;
    if (map) {
      map.setView([cercano.lat, cercano.lon], 13);
      markers[cercano.id].openPopup();
    }
  }, (err) => {
    const motivos = {
      1: 'Has denegado el permiso de ubicación.',
      2: 'No se ha podido obtener tu ubicación.',
      3: 'La búsqueda de ubicación ha tardado demasiado.'
    };
    status.textContent = motivos[err.code] || 'No se ha podido obtener tu ubicación.';
  }, { timeout: 10000, maximumAge: 60000 });
}

/* 6. APARICIÓN SUAVE AL HACER SCROLL ------------------------------ */
function initReveal() {
  const items = document.querySelectorAll('.reveal');
  if (reduceMotion || !('IntersectionObserver' in window)) {
    items.forEach((el) => el.classList.add('is-visible'));
    return;
  }
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e) => {
      if (e.isIntersecting) { e.target.classList.add('is-visible'); io.unobserve(e.target); }
    });
  }, { threshold: 0.15 });
  items.forEach((el) => io.observe(el));
}
