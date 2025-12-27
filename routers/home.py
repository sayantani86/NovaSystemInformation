import os
import numpy as np
import pandas as pd
from datetime import date

from fastapi import APIRouter, HTTPException 
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from file_reader import FileReader

router = APIRouter()

@router.get("/non_compliant_hours")
async def cards(start_date: str, end_date: str):
    """
    Fetch well card data for a date range.
    Dates should be in ISO format: YYYY-MM-DD
    """
    try:
        data_dir = os.getenv("DATA_FOLDER")

        if not data_dir:
            raise HTTPException(status_code=500, detail="DATA_FOLDER environment variable not set")

        outputs = []

        for f in os.listdir("/Users/sayantanidasgupta/data/nova"):
            reader = FileReader(f"/Users/sayantanidasgupta/data/nova/{f}")
            outputs.append(reader.non_compliant_hours(start_date, end_date))
        
        return JSONResponse(content=outputs)

    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid date format: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")
    

@router.get("/compressor_breakdown/{start_date}/{end_date}")
def compressor_breakdown(start_date: str, end_date: str):
    """
    Fetch monthly oil production data for a date range.
    Dates should be in ISO format: YYYY-MM-DD
    """
    print(start_date, end_date)
    try:
        # Validate date format
        sd = date.fromisoformat(start_date)
        ed = date.fromisoformat(end_date)
        
        if sd > ed:
            raise HTTPException(status_code=400, detail="start_date must be on or before end_date")
        
        # Load CSV
        data = {
                    "compressor": {
                    "offline_hours": 12.8,
                    "online_hours": 2.4
                    },
                    "line_pressure": {
                    "offline_hours": 12.8,
                    "online_hours": 2.4
                    },
                    "gas_injection_pressure": {
                    "offline_hours": 12.8,
                    "online_hours": 2.4
                    }
            }


        
        
        return JSONResponse(content={"data": data})
    
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid date format: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")