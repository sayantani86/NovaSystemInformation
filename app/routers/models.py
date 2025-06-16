from pydantic import BaseModel

class ActionableParametersForWellGroup(BaseModel):
    choke: float

class WhatIfRequest(BaseModel):
    actionableParameters: ActionableParametersForWellGroup
    productionWellList: list[float]

