# Configuración inicial de la BD "almichain" (se ejecuta UNA vez con "odoo shell").
# 04-odoo-docker.sh cambia __ADMIN__ por la contraseña generada antes de pasarlo
# por la entrada estándar: la contraseña no aparece en la línea de comandos.

# Usuario admin: contraseña segura, español y hora de Madrid
admin = env.ref('base.user_admin')
admin.write({'password': '__ADMIN__', 'lang': 'es_ES', 'tz': 'Europe/Madrid'})

# Empresa en España y en euros (así se carga el plan contable español con el IVA)
env.ref('base.EUR').active = True
env.company.write({
    'name': 'Almi-Chain',
    'country_id': env.ref('base.es').id,
    'currency_id': env.ref('base.EUR').id,
})

# Dirección pública fija y dirección interna para generar los PDF
p = env['ir.config_parameter'].sudo()
p.set_param('web.base.url', 'https://odoo.almichain.lan')
p.set_param('web.base.url.freeze', 'True')
p.set_param('report.url', 'http://localhost:8069')

# Cliente genérico para las ventas del TPV sin cliente (factura simplificada)
if not env['res.partner'].search([('name', '=', 'Cliente de contado')], limit=1):
    env['res.partner'].create({'name': 'Cliente de contado', 'country_id': env.ref('base.es').id})

env.cr.commit()
print('Configuración inicial aplicada')
