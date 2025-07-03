from pydantic import BaseModel

class ActionableParametersForWellGroup(BaseModel):
    choke: float

class WhatIfRequest(BaseModel):
    productionWellList: list[float] = []
    startDate: str
    endDate: str

