# auth.py
from datetime import datetime
import jwt
from typing import Optional
from fastapi import Request, HTTPException, status
import requests
import httpx

user_mgmt_base_url="http://172.30.2.104:8001"
# Replace this with your real secret (or load from env/config)
# SECRET_KEY = "secret"

# def verify_jwt_from_request(request: Request) -> Optional[dict]:
#     """
#     Extracts the JWT from the `Authorization` header, verifies it,
#     and returns the decoded payload. Raises HTTPException(401) on failure.
#     """
#     auth_header = request.headers.get("authorization")
#     if not auth_header:
#         print("Bearer token not sent")
#         raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="Missing Authorization header"
#         )

#     if not auth_header.startswith("Bearer "):
#         raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="invalid Authorization header"
#         )

#     token = auth_header.split(" ", 1)[1]  # grab everything after "Bearer "

#     try:
#         payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
#         email = payload['email']
#         exp   = payload['exp']
#         debug_write(f"Email: {email}")
#         debug_write(f"Expiration: {exp}")

#         current_utc   = datetime.utcnow().timestamp()

#         if int(exp) > int(current_utc):
#             print("token is still valid")
#         else:
#             raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="Token expired")

#         #TO DO - Verify user id and return HTTP_401_UNAUTHORIZED if user does not exist
    
#     except jwt.ExpiredSignatureError:
#         raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="Token has expired"
#         )
        
#     except jwt.InvalidTokenError:
#         raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="Invalid token"
#         )

#     return payload

async def verify_jwt_from_request(request: Request) -> str:
    url = f"{user_mgmt_base_url}/validate-token"

    auth_header = request.headers.get("authorization")
    if not auth_header:
        print("Bearer token not sent")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header"
        )

    if not auth_header.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="invalid Authorization header"
        )

    token = auth_header.split(" ", 1)[1]  # grab everything after "Bearer "

    headers = {
        "Authorization": f"Bearer {token}"
    }

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=headers)
    except httpx.RequestError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Token validation service unreachable: {str(e)}"
        )

    
    # # Make request to external token validation service
    # try:
    #     response = requests.get(url, headers=headers)
    # except requests.RequestException as e:
    #     raise HTTPException(
    #         status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
    #         detail=f"Token validation service unreachable: {str(e)}"
    #     )
    
    if response.status_code == 200:
        print("validated")
        return token
    else:
        print(f"Request failed with status code: {response.status_code}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication Failed"
        )
