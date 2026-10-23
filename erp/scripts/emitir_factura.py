#!/usr/bin/env python3
"""
emitir_factura.py · Caso de uso automatizado de extremo a extremo:
EMISIÓN DE UNA FACTURA en Odoo 19 a través de su API (JSON-2, HTTPS).

  1. Busca los productos de la carta.
  2. Busca al cliente (por NIF o por nombre) y, si no existe, lo crea.
  3. Crea la factura de cliente con sus líneas (el IVA sale del producto).
  4. La valida: Odoo le asigna número (p. ej. FAC/2026/00001).
  5. Comprueba que ha quedado publicada y muestra el resumen.

Seguridad:
  - Se conecta por HTTPS y verifica el certificado de la CA de Almi-Chain.
  - Usa la clave API de un usuario que SOLO tiene permisos de facturación.
  - La clave se lee de un fichero con permisos 600, nunca del código.

Uso:
  python3 emitir_factura.py --cliente "Ane Etxeberria" \
      --linea "Menú del día:2" --linea "Txakoli (botella):1"

  --linea "PRODUCTO:CANTIDAD[:PRECIO]"  (el precio es opcional; por defecto, el de la ficha)
  --nif, --email                       (opcionales, datos del cliente)
  --borrador                           (crea la factura sin validarla)

Configuración (variables de entorno, con estos valores por defecto):
  ODOO_URL=https://odoo.almichain.lan   ODOO_BD=almichain
  ODOO_CLAVE_API=~/.config/almichain/odoo-apikey
  ODOO_CA=/etc/ssl/almichain/almichain-ca.crt
Solo usa la biblioteca estándar de Python.
"""
import argparse
import datetime
import json
import os
import ssl
import stat
import sys
import urllib.error
import urllib.request

URL = os.environ.get("ODOO_URL", "https://odoo.almichain.lan").rstrip("/")
BD = os.environ.get("ODOO_BD", "almichain")
FICHERO_CLAVE = os.path.expanduser(os.environ.get("ODOO_CLAVE_API", "~/.config/almichain/odoo-apikey"))
CA = os.environ.get("ODOO_CA", "/etc/ssl/almichain/almichain-ca.crt")


def leer_clave():
    try:
        modo = stat.S_IMODE(os.stat(FICHERO_CLAVE).st_mode)
    except FileNotFoundError:
        sys.exit(f"No encuentro la clave API en {FICHERO_CLAVE}. Mira erp/README.md (usuario de automatización).")
    if modo & 0o077:
        sys.exit(f"{FICHERO_CLAVE} tiene permisos {oct(modo)}: cualquiera podría leer la clave. Ejecuta: chmod 600 {FICHERO_CLAVE}")
    with open(FICHERO_CLAVE, encoding="utf-8") as f:
        return f.read().strip()


class Odoo:
    """Cliente mínimo de la API JSON-2 de Odoo 19: POST /json/2/<modelo>/<método>."""

    def __init__(self, url, bd, clave, ca):
        self.url = url
        self.cabeceras = {
            "Authorization": f"bearer {clave}",
            "X-Odoo-Database": bd,
            "Content-Type": "application/json; charset=utf-8",
            "User-Agent": "almichain-facturas/1.0",
        }
        self.ssl = ssl.create_default_context(cafile=ca if os.path.exists(ca) else None)

    def llamar(self, modelo, metodo, **parametros):
        parametros.setdefault("context", {"lang": "es_ES"})
        peticion = urllib.request.Request(
            f"{self.url}/json/2/{modelo}/{metodo}",
            data=json.dumps(parametros).encode(),
            headers=self.cabeceras,
            method="POST",
        )
        try:
            with urllib.request.urlopen(peticion, context=self.ssl, timeout=60) as r:
                return json.loads(r.read() or "null")
        except urllib.error.HTTPError as e:
            try:
                error = json.loads(e.read())
                mensaje = error.get("message") or error
            except ValueError:
                mensaje = e.reason
            sys.exit(f"Odoo respondió {e.code} en {modelo}.{metodo}: {mensaje}")
        except urllib.error.URLError as e:
            sys.exit(f"No se puede conectar con {self.url}: {e.reason}")


def un_id(resultado):
    """create() devuelve una lista de ids; nos quedamos con el primero."""
    return resultado[0] if isinstance(resultado, list) else resultado


def leer_linea(texto):
    partes = texto.rsplit(":", 2) if texto.count(":") >= 2 else texto.rsplit(":", 1)
    if len(partes) < 2:
        sys.exit(f'Línea mal escrita: "{texto}". Formato: "PRODUCTO:CANTIDAD[:PRECIO]"')
    try:
        nombre, cantidad = partes[0].strip(), float(partes[1].replace(",", "."))
        precio = float(partes[2].replace(",", ".")) if len(partes) == 3 else None
    except ValueError:
        sys.exit(f'Cantidad o precio no válidos en "{texto}"')
    if cantidad <= 0:
        sys.exit(f'La cantidad tiene que ser mayor que 0 en "{texto}"')
    return nombre, cantidad, precio


def main():
    ap = argparse.ArgumentParser(description="Emite una factura de cliente en Odoo (Almi-Chain).")
    ap.add_argument("--cliente", required=True, help="Nombre del cliente")
    ap.add_argument("--nif", help="NIF/CIF del cliente, con prefijo de país (p. ej. ESB12345678)")
    ap.add_argument("--email", help="Email del cliente")
    ap.add_argument("--linea", action="append", required=True, help='"PRODUCTO:CANTIDAD[:PRECIO]" (se puede repetir)')
    ap.add_argument("--borrador", action="store_true", help="Crear la factura sin validarla")
    a = ap.parse_args()

    odoo = Odoo(URL, BD, leer_clave(), CA)

    # 1. Productos de la carta
    lineas = []
    for texto in a.linea:
        nombre, cantidad, precio = leer_linea(texto)
        prod = odoo.llamar("product.product", "search", domain=[["name", "=", nombre], ["sale_ok", "=", True]], limit=1)
        if not prod:
            sys.exit(f'No existe el producto "{nombre}" (o no se puede vender). Créalo en Odoo: Facturación > Clientes > Productos.')
        valores = {"product_id": prod[0], "quantity": cantidad}
        if precio is not None:
            valores["price_unit"] = precio
        lineas.append([0, 0, valores])

    # 2. Cliente (después de comprobar los productos, para no crear clientes si algo falla)
    dominio = [["vat", "=", a.nif]] if a.nif else [["name", "=", a.cliente]]
    ids = odoo.llamar("res.partner", "search", domain=dominio, limit=1)
    if ids:
        cliente_id = ids[0]
        print(f"Cliente existente: {a.cliente} (id {cliente_id})")
    else:
        datos = {"name": a.cliente}
        if a.nif:
            datos["vat"] = a.nif
        if a.email:
            datos["email"] = a.email
        cliente_id = un_id(odoo.llamar("res.partner", "create", vals_list=[datos]))
        print(f"Cliente nuevo creado: {a.cliente} (id {cliente_id})")

    # 3. Factura de cliente
    factura_id = un_id(odoo.llamar("account.move", "create", vals_list=[{
        "move_type": "out_invoice",
        "partner_id": cliente_id,
        "invoice_date": datetime.date.today().isoformat(),
        "invoice_line_ids": lineas,
    }]))

    # 4. Validar (asigna número)
    if not a.borrador:
        odoo.llamar("account.move", "action_post", ids=[factura_id])

    # 5. Comprobación
    f = odoo.llamar("account.move", "read", ids=[factura_id],
                    fields=["name", "state", "invoice_date", "amount_untaxed", "amount_tax", "amount_total"])[0]
    print()
    print(f"Factura {f['name']}  ·  estado: {f['state']}  ·  fecha: {f['invoice_date']}")
    print(f"  Base imponible: {f['amount_untaxed']:.2f} €")
    print(f"  IVA:            {f['amount_tax']:.2f} €")
    print(f"  TOTAL:          {f['amount_total']:.2f} €")
    print("  En Odoo: Facturación > Clientes > Facturas")
    if not a.borrador and f["state"] != "posted":
        sys.exit("ERROR: la factura no ha quedado publicada.")


if __name__ == "__main__":
    main()
