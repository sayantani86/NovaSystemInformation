from fastapi import APIRouter, HTTPException 
from fastapi.responses import JSONResponse
from datetime import date
import os
import pandas as pd
import numpy as np

router = APIRouter()
@router.get("/compressor_details")
def get_compressor_details():
    try:
        data = [
                    {
                    "date": "09/01/2025",
                    "name": "Compressor_1",
                    "suction_pressure":  980,
                    "discharge_pressure": 123.15
                    }
                ]

        
        return JSONResponse(content={"data": data})
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")