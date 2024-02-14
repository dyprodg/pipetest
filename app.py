from flask import Flask, jsonify
import requests

app = Flask(__name__)

@app.route('/api')
def call_external_api():
    response = requests.get('https://api.github.com')
    return jsonify(response.json())

if __name__ == '__main__':
    app.run(debug=True)
