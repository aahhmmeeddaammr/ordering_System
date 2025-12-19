@echo off
REM Start Customer Service on port 5004
start "Customer Service" cmd /k "cd customer-service && cd app && ..\env\Scripts\activate.bat && set FLASK_APP=app.py && set FLASK_RUN_PORT=5004 && set FLASK_ENV=development && flask run --host=127.0.0.1"

REM Start Inventory Service on port 5002
start "Inventory Service" cmd /k "cd inventory-service && cd app && ..\env\Scripts\activate.bat && set FLASK_APP=app.py && set FLASK_RUN_PORT=5002 && set FLASK_ENV=development && flask run --host=127.0.0.1"

REM Start Notification Service on port 5005
start "Notification Service" cmd /k "cd notification-service && cd app && ..\env\Scripts\activate.bat && set FLASK_APP=app.py && set FLASK_RUN_PORT=5005 && set FLASK_ENV=development && flask run --host=127.0.0.1"

REM Start Order Service on port 5004
start "Order Service" cmd /k "cd order-service && cd app && ..\env\Scripts\activate.bat && set FLASK_APP=app.py && set FLASK_RUN_PORT=5001 && set FLASK_ENV=development && flask run --host=127.0.0.1"

REM Start Pricing Service on port 5005
start "Pricing Service" cmd /k "cd pricing-service && cd app && ..\env\Scripts\activate.bat && set FLASK_APP=app.py && set FLASK_RUN_PORT=5003 && set FLASK_ENV=development && flask run --host=127.0.0.1"

echo All services are starting...
echo Order Service: http://localhost:5001
echo Inventory Service: http://localhost:5002
echo Pricing Service: http://localhost:5003
echo Customer Service: http://localhost:5004
echo Notification Service: http://localhost:5005
