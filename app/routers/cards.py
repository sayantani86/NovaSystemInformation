from fastapi import APIRouter, HTTPException 
from fastapi.responses import JSONResponse
from datetime import date
import os
import pandas as pd
import numpy as np

router = APIRouter()

@router.get("/cards/{start_date}/{end_date}")
async def get_well_cards(start_date: str, end_date: str):
    """
    Fetch well card data for a date range.
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
        data_dir = os.getenv("DATA_FOLDER")
        if not data_dir:
            raise HTTPException(status_code=500, detail="DATA_FOLDER environment variable not set")
        
        csv_path = os.path.join(data_dir, "Cinco 1H_time_collapsed.csv")
        
        if not os.path.exists(csv_path):
            raise HTTPException(status_code=404, detail=f"CSV file not found: {csv_path}")
        
        df = pd.read_csv(csv_path)
        df = df.replace([np.nan, np.inf, -np.inf], None)
        data = df.astype(object).to_dict(orient="records")
        
        return JSONResponse(content={"data": data, "count": len(data), "start_date": start_date, "end_date": end_date})

    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid date format: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")
    


@router.get("/monthly_oil_production/{start_date}/{end_date}")
def get_monthly_oil_production(start_date: str, end_date: str):
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
        data = [    
                    {
                        "name": "January",
                        "value": 1,
                        "actual_production":  40,
                        "predicted_production": 45,
                        "delta": 5,
                        "start_date": start_date,
                        "end_date": end_date
                    }, 
                    {
                        "name": "February",
                        "value": 2,
                        "actual_production":  50,
                        "predicted_production": 55,
                        "delta": 5,
                        "start_date": start_date,
                        "end_date": end_date
                    }
                ]

        
        
        return JSONResponse(content={"data": data})
    
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