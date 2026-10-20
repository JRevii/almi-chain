# Normas del repositorio

## Ramas
- `main`: solo lo que funciona y está documentado. No se trabaja directamente aquí.
- Una rama por tarea: `feat/recreativa-mame`, `feat/web-slideshow`, `docs/plano-red`, `fix/terraform-nginx`…
- Para integrar en `main`: Pull Request y que lo revise al menos otra persona del equipo.

## Commits
Formato: `tipo(área): descripción corta en presente`

Tipos: `feat` (algo nuevo), `fix` (arreglo), `docs` (documentación), `chore` (mantenimiento), `test` (pruebas).

Ejemplos:
- `feat(recreativa): añadir script de optimización del arranque`
- `docs(redes): plano de red con WDS`
- `test(backups): prueba de restauración del 20/10`

## Lo que NUNCA se sube
- Contraseñas, claves AWS, tokens de DuckDNS, claves `.pem`, ficheros `.env` → van en un gestor de contraseñas o en variables de entorno. Se sube un `.env.example` sin valores reales.
- ISOs, discos de VM (`.vdi`, `.vmdk`, `.ova`) y ROMs de MAME.
- Estado de Terraform (`terraform.tfstate`).

## Seguimiento
Cada tarjeta del Kanban enlaza su rama o PR, para que se vea quién hace cada tarea y cuándo.
