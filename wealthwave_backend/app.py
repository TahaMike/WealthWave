from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import pickle
from tensorflow.keras.models import load_model
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Load models
with open('model/clf_priority.pkl', 'rb') as f:
    clf_priority = pickle.load(f)

with open('model/clf_level.pkl', 'rb') as f:
    clf_level = pickle.load(f)

with open('model/scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)

#lstm_model = load_model('model/lstm_model.h5')
# lstm_model = load_model('model/lstm_model.h5', compile=False)
lstm_model = load_model('model/lstm_model.keras')


@app.route('/')
def index():
    return "🚀 WealthWave AI API is running!"

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        # Expecting: { "date": "2025-04-24", "amount": 450.0 }

        # Parse date
        date = pd.to_datetime(data.get('date'), errors='coerce')
        if pd.isna(date):
            return jsonify({'error': 'Invalid date format'}), 400

        amount = float(data.get('amount', 0.0))
        day = date.day
        month = date.month
        year = date.year

        # Feature vector
        input_features = pd.DataFrame([{
            'amount': amount,
            'day': day,
            'month': month,
            'year': year
        }])

        # Priority & Level Predictions
        priority_pred = clf_priority.predict(input_features)[0]
        level_pred = clf_level.predict(input_features)[0]

        return jsonify({
            'priority': int(priority_pred),
            'level': int(level_pred),
            'message': 'Successfully predicted classification'
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/predict-next-amount', methods=['POST'])
def predict_next_amount():
    try:
        data = request.get_json()
        history = data.get('history')  # expects list of past 5 amounts

        if not history or len(history) < 5:
            return jsonify({'error': 'Provide at least 5 previous amounts'}), 400

        history = np.array(history[-5:]).reshape(-1, 1)
        history_scaled = scaler.transform(history)
        X_seq = history_scaled.reshape((1, 5, 1))

        predicted_scaled = lstm_model.predict(X_seq)[0][0]
        predicted_amount = scaler.inverse_transform([[predicted_scaled]])[0][0]

        return jsonify({
            'predicted_next_amount': round(predicted_amount, 2),
            'message': 'Predicted next transaction amount'
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True, port=5000)
