from fastapi import APIRouter, HTTPException 
from fastapi.responses import JSONResponse
from datetime import date
import os
import pandas as pd
import numpy as np

router = APIRouter()
@router.get("/oil_impact_details/{well_name}/{type}")
def get_oil_impact_details(well_name: str, type: str):
    try:
        # Load CSV
        data = [
                    {
                    "date": "09/01/2025",
                    "line_pressure": 36,
                    "gas_injection_pressure":  1330,
                    "type": "Natural Flow"
                    },
                    {
                    "date": "09/01/2025",
                    "line_pressure": 0,
                    "gas_injection_pressure":  0,
                    "type": "Shut In"
                    },
                    {
                    "date": "09/01/2025",
                    "line_pressure": 36,
                    "gas_injection_pressure":  1330,
                    "type": "Continuous Gas Lift"
                    }

                ]


        
        
        return JSONResponse(content={"data": data})
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")