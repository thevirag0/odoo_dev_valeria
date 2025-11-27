from odoo import models, fields, api

class Artista(models.Model):
    _name = 'galeria.artista'
    _description = 'Artista'
    
    name = fields.Char(string='Nombre', required=True)
    biografia = fields.Text(string='Biografía')
    especialidad = fields.Selection([
        ('pintura', 'Pintura'),
        ('escultura', 'Escultura'),
        ('fotografia', 'Fotografía'),
        ('digital', 'Arte Digital'),
        ('mixto', 'Mixto')
    ], string='Especialidad')
    email = fields.Char(string='Email')
    telefono = fields.Char(string='Teléfono')
    activo = fields.Boolean(string='Activo', default=True)
