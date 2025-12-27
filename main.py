from typing import Union

from fastapi import FastAPI
from pydantic import BaseModel
import os
import json
from datetime import datetime
from typing import Optional
from dotenv import load_dotenv
load_dotenv() # take environment variables from .env file
from pydantic import BaseModel

app = FastAPI()

# csv_reader = Filereader("output_model4_LIP_whatif.csv")

class Item(BaseModel):
    name: str
    price: float
    is_offer: Union[bool, None] = None


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


@app.put("/items/{item_id}")
def update_item(item_id: int, item: Item):
    return {"item_name": item.name, "item_id": item_id}

# @app.get("/production-loss")
# def get_production_loss(
#     start_date: datetime,
#     end_date: datetime,
#     refid: Optional[str] = None
# ):
#     """
#     Aggregate production loss within a date range.
#     Optionally filter by refid.
#     """
#     return csv_reader.aggregate_production_loss(
#         start_date=start_date,
#         end_date=end_date,
#         refid=refid
#     )
# @app.get("/production-oil-rate")
# def get_production_oil_rate(
#     start_date: datetime,
#     end_date: datetime,
#     refid: Optional[str] = None
# ):
#     """
#     Aggregate production oil rate within a date range.
#     Optionally filter by refid.
#     """

#     return csv_reader.aggregate_production_oil_rate(
#         start_date=start_date,
#         end_date=end_date,
#         refid=refid
#     )


from routers import wells, oil, compressor, home
app.include_router(home.router) 
app.include_router(wells.router) 
app.include_router(oil.router) 
app.include_router(compressor.router) 
