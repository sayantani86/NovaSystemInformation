from fastapi import APIRouter, HTTPException 
from fastapi.responses import JSONResponse
from datetime import date
import os
import pandas as pd
import numpy as np

router = APIRouter()
@router.get("/wells")
async def get_well_cards():

    data=[
            {
                "well_id": 1,
                "lost_production_value" :  84.2,
                "lost_production_unit" :  "BBL",
                "hours" :  84,
                "area":"North"
            }
        ]
    
    return JSONResponse(content={"data": data})


    