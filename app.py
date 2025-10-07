from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
#Hola cambio pequeño

app = Flask(__name__)

CORS(app, resources={r"/imagenes": {"origins": "http://localhost:22005"}})

DB_PATH = "/var/www/sha256/imagenes.db"  # ruta a tu base sqlite

def get_image_by_name(nombre):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT base64 FROM imagenes WHERE nombre = ?", (nombre,))
    result = c.fetchone()
    conn.close()
    return result[0] if result else None

@app.route("/imagenes", methods=["POST"])
def imagenes():
    data = request.get_json()  # espera JSON { "nombre": "..." }
    if not data or "nombre" not in data:
        return jsonify({"status": "error", "message": "Debes enviar un nombre"}), 400
    
    nombre = data["nombre"]
    base64_img = get_image_by_name(nombre)

    if base64_img:
        return jsonify({"status": "ok", "nombre": nombre, "imagen": base64_img})
    else:
        return jsonify({"status": "error", "message": "Imagen no encontrada"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
