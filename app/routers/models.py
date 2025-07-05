from pydantic import BaseModel

class NearbyComponentRequest(BaseModel):
    productionWellList: list[float] = []

class WhatIfRequest(BaseModel):
    productionWellList: list[float] = []
    startDate: str
    endDate: str

