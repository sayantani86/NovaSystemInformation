from fastapi import APIRouter, HTTPException 
from fastapi.responses import JSONResponse
from datetime import date
import os
import pandas as pd
import numpy as np

router = APIRouter()
@router.get("/wells")
async def get_well_cards():
    """
    Fetch well card data for a date range.
    Dates should be in ISO format: YYYY-MM-DD
    """

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


    