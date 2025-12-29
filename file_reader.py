import os
import pandas as pd
import numpy as np
from datetime import datetime

class FileReader:    
    def __init__(self, filename: str):
        self.filename = filename
    
    def read_csv(self) -> pd.DataFrame:
        # csv_path = os.path.join(os.getenv("DATA_FOLDER"), self.filename)
        # if not os.path.exists(csv_path):
        #     raise FileNotFoundError(f"CSV file not found: {csv_path}")
        
        #df = pd.read_csv(self.filename)
        df = pd.read_excel(self.filename)
        df = df.replace([np.nan, np.inf, -np.inf], None)

        return df

    def non_compliant_hours(
        self,
        start_date,
        end_date,
        refid: str = None
    ) -> float:
        df = self.read_csv()

        df['timestamp'] = pd.to_datetime(
            df['timestamp'],
            format="%d/%m/%Y %H:%M",
            errors="coerce"
        )
        df = df.sort_values(by=['timestamp'])

        # filter by refid
        if refid:
            df = df[df['refid'] == refid]

        start_date = datetime.strptime(start_date, "%d-%m-%Y %H:%M:%S")
        end_date = datetime.strptime(end_date, "%d-%m-%Y %H:%M:%S")
        
        # Filter by date range
        temp = (df['timestamp'] >= start_date) & (df['timestamp'] <= end_date)
        filtered_df = df[temp]

        filtered_df['YYYYMM'] = filtered_df['timestamp'].dt.year.astype(str) + '-' + filtered_df['timestamp'].dt.month.astype(str)

        # line pressure 2 high
        line_pressure_psi = filtered_df[filtered_df['Line Pressure actual'] > 150]
        originals = list(line_pressure_psi.index)
        line_pressure_psi = line_pressure_psi.reset_index(drop=True)

        lp_diff = []

        for (index, item) in enumerate(line_pressure_psi['timestamp']):
            if index == len(line_pressure_psi) - 1:
                break
            if originals[index + 1] - originals[index] == 1:
                hours_d = (line_pressure_psi.loc[index + 1, 'timestamp'] - item).total_seconds() / 3600
                lp_diff.append(hours_d)

        # gas pressure 2 low
        gas_pressure_psi = filtered_df[filtered_df['Gas Injection Pressure actual'] < 1000]
        originals_gas = list(gas_pressure_psi.index)
        gas_pressure_psi = gas_pressure_psi.reset_index(drop=True)

        gp_diff = []

        for (index, item) in enumerate(gas_pressure_psi['timestamp']):
            if index == len(gas_pressure_psi) - 1:
                break
            
            if originals_gas[index + 1] - originals_gas[index] == 1:
                hours_d = (gas_pressure_psi.loc[index + 1, 'timestamp'] - item).total_seconds() / 3600
                gp_diff.append(hours_d)

        # lost production
        lost_hours = []
        lost_prod = filtered_df[filtered_df['pred_barrels_interval'] < filtered_df['barrels_interval']].reset_index(drop=True)

        for (index, item) in enumerate(lost_prod['timestamp']):
            if index == 0:
                lost_hours.append(None)
                continue
            
            hours_d = (item - lost_prod['timestamp'][index - 1]).total_seconds() / 3600
            lost_hours.append(hours_d)

        outputs = []
        outputs.append(('wellname', df['wellname_x'].unique()[0]))
        outputs.append(('lost_production', np.abs(filtered_df['barrels_interval'].sum() - filtered_df['pred_barrels_interval'].sum())))
        outputs.append(['line_pressure_nph', pd.Series(lp_diff).sum()])
        outputs.append(('line_pressure_nph_wells_count', 1))
        outputs.append(('gas_injection_pressure_nph', pd.Series(gp_diff).sum()))
        outputs.append(('gas_injection_pressure_nph_wells_count', 1))

        
        # monthly production
        actualOilProd = filtered_df.groupby('YYYYMM')['barrels_interval'].sum()
        predPred = filtered_df.groupby('YYYYMM')['pred_barrels_interval'].sum()
        cumDelta = filtered_df.groupby('YYYYMM')['pred_cumulative_barrels'].sum()

        response = []
        for item in filtered_df.groupby('YYYYMM').groups:
            response.append({
                "name": item,
                "actual_production":  actualOilProd.loc[item],
                "predicted_production": predPred.loc[item],
                "cumulative_delta": cumDelta.loc[item]
            })


        return {
            "non_compliant_hours": outputs,
            "monthly_production": response
        }
    

if __name__ == '__main__':
    a = FileReader("/Users/sayantanidasgupta/Downloads/5_well_files/flane_1h_time_collapsed.csv")
    a.aggregate_production_oil_rate('01-01-2024', '01-02-2024', None)