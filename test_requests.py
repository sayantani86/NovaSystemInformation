import requests

def test_read_asset():
    resp = requests.get("http://localhost:8080/ADDAX")

    return resp.status_code == 200

def test_read_asset_ironiq():

    r=requests.get("http://localhost:8000/sysinfo/assets/ironiq/ADDAX HUNTER 1H/", params={'st_dt': '2024-01-01', 'et_dt': '2024-01-08'})

    return r.status_code == 200
