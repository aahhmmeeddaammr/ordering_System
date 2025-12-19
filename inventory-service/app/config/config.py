import os

def configure_app(app):
    app.config["PORT"] = os.getenv("PORT")
    app.config["DB_HOST"] = os.getenv("DB_HOST")
    app.config["DB_USER"] = os.getenv("DB_USER")
    app.config["DB_PASS"] = os.getenv("DB_PASS")
    app.config["DB_NAME"] = os.getenv("DB_NAME")
