import requests
import json

url = "http://127.0.0.1:8081/api/auth/authenticate"
headers = {
    "Content-Type": "application/json"
}
data = {
    "email": "manager1@gmail.com",
    "password": "password"  # Using a dummy password, we expect 403 or 200, not 401 if logic is right about CORS
}

origins = [
    None,
    "http://localhost",
    "http://127.0.0.1",
    "http://localhost:55016",
    "http://127.0.0.1:55016",
    "http://localhost:9100",
    "http://127.0.0.1:9100"
]

print(f"Testing URL: {url}")

for origin in origins:
    current_headers = headers.copy()
    if origin:
        current_headers["Origin"] = origin
    
    try:
        print(f"Testing Origin: {origin}")
        response = requests.post(url, json=data, headers=current_headers)
        print(f"Status: {response.status_code}")
        print(f"Headers: {response.headers}")
        print(f"Content: {response.text[:100]}")
        print("-" * 20)
    except Exception as e:
        print(f"Error: {e}")
