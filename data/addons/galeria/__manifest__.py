{
    'name': 'Galeria de Arte',
    'version': '1.0',
    'summary': 'Gestión de galería de arte con exposiciones temporales',
    'description': 'Módulo para gestionar artistas, obras y exposiciones',
    'category': 'Uncategorized',
    'author': 'Valeria',
    'website': '',
    'license': 'LGPL-3',
    'depends': ['base', 'website', 'crm', 'sale', 'stock', 'project'],
    'data': [
        'security/ir.model.access.csv',
	'views/artista_views.xml',
    ],
    'demo': [
        # Datos de demostración
    ],
    'installable': True,
    'application': True,
    'auto_install': False,
}
