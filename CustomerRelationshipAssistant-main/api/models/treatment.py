
from marshmallow import Schema, fields
from sqlalchemy import Column, String

from .entity import Entity, Base


class Treatment(Entity, Base):
    __tablename__ = 'collinw.current_treatments'

    treatment_code = Column(String)
    product = Column(String)
    source_system = Column(String)
    variant = Column(Integer)
    _id = Column(Integer)
    id_type = Column(String)
    treatment_text = Column(String)
    treatment_title = Column(String)

#     def __init__(self, treatment_code, product, source_system, variant,
#                      _id, id_type, treatment_text, treatment_title, created_by ):
#         Entity.__init__(self, created_by)
#         self.treatment_code     = treatment_id
#         self.product            = product
#         self.source_system      = source_system
#         self.variant            = variant
#         self._id                = _id
#         self.id_type            = id_type
#         self.treatment_text     = treatment_text
#         self.treatment_title    = treatment_title
      
#     def __repr__(self):
#         return '<Treatment(name={self.description!r})>'.format(self=self) 

# class TreatmentSchema(Schema):
#     current_treatment_id = fields.Number()
#     treatment_code = fields.Str()
#     product = fields.Str()
#     source_system = fields.Str()
#     variant = fields.Number()
#     _id = fields.Number()
#     id_type = fields.Str()
#     treatment_text = fields.Str()
#     treatment_title = fields.Str()
#     created_at = fields.DateTime()
#     updated_at = fields.DateTime()
#     last_updated_by = fields.Str()
