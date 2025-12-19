from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
from .config.config import configure_app

def create_app():
    load_dotenv()
    app = Flask(__name__)
    
    CORS(app, resources={r"/*": {"origins": "*"}})
    
    configure_app(app)

    from .routes.routes import register_routes
    register_routes(app)

    return app
