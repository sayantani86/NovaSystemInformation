import pandas as pd
import numpy as np
import os


class Filereader:    
    def __init__(self, filename: str):
        self.filename = filename
    
    def read_csv(self) -> pd.DataFrame:
        csv_path = os.path.join(os.getenv("DATA_FOLDER"), self.filename)
        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"CSV file not found: {csv_path}")
        
        df = pd.read_csv(csv_path)
        df = df.replace([np.nan, np.inf, -np.inf], None)
        return df
    
    def aggregate_production_loss(
        self,
        start_date,
        end_date,
        refid: str = None
    ) -> dict:
        dict_items={
            "start_date": start_date,
            "end_date": end_date,
            "refid": refid,
            "total_production_loss": 0,
            "average_production_loss": 0
        }
        df = self.read_csv()
        df['timestamp'] = pd.to_datetime(
            df['timestamp'],
            format="%d-%m-%Y %H:%M",
            errors="coerce"
        )
        start_date = pd.to_datetime(start_date)
        end_date = pd.to_datetime(end_date)
        
        # Filter by date range
        temp = (df['timestamp'] >= start_date) & (df['timestamp'] <= end_date)
        filtered_df = df.loc[temp]
        
        # filter by refid
        if refid:
            filtered_df = filtered_df[filtered_df['refid'] == refid]
        
        # Aggregate barrels_diff_pred_minus_actual
        dict_items["total_production_loss"] = filtered_df['barrels_diff_pred_minus_actual'].sum()

        if not filtered_df['barrels_diff_pred_minus_actual'].isnull().all():
            dict_items["average_production_loss"] = filtered_df['barrels_diff_pred_minus_actual'].mean()

        
        return dict_items


    def aggregate_production_oil_rate(
        self,
        start_date,
        end_date,
        refid: str = None
    ) -> float:
        df = self.read_csv()
        df['timestamp'] = pd.to_datetime(
            df['timestamp'],
            format="%d-%m-%Y %H:%M",
            errors="coerce"
        )
        start_date = pd.to_datetime(start_date)
        end_date = pd.to_datetime(end_date)
        
        # Filter by date range
        temp = (df['timestamp'] >= start_date) & (df['timestamp'] <= end_date)
        filtered_df = df.loc[temp]
        
        # filter by refid
        if refid:
            filtered_df = filtered_df[filtered_df['refid'] == refid]

        # Aggregate Production Oil Rate
        total_rate = filtered_df['Production Oil Rate'].sum()

        print("Total Production  Oil Rate:", total_rate)
        
        return total_rate
    