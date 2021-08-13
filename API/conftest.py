import pytest
from app import app as flask_app

def test_get_request():
    with flask_app.test_client() as c:
        response = c.get("http://127.0.0.1:5000/")
    assert response.status_code == 200
