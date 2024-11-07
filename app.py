from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
import joblib
import pandas as pd
import numpy as np

app = Flask(__name__)
CORS(app)

# Load the models and scaler
log_model = joblib.load('logistic_regression_model.pkl')  # Path to your saved Logistic Regression model
rf_model = joblib.load('random_forest_model.pkl')          # Path to your saved Random Forest model
xgb_model = joblib.load('xgboost_model.pkl')               # Path to your saved XGBoost model
scaler = joblib.load('scaler.pkl')                          # Path to your saved StandardScaler

# Pre-calculated accuracy for each model
accuracy_log = 0.68 # Replace with your actual accuracy for Logistic Regression
accuracy_rf = 0.78   # Replace with your actual accuracy for Random Forest
accuracy_xgb = 0.79  # Replace with your actual accuracy for XGBoost

@app.route('/predict', methods=['POST'])
def predict():
    # Get the input data from the request
    data = request.get_json(force=True)
    input_data_df = pd.DataFrame([
	data['sex'],  # 1 for Male, 0 for Female
        data['age'],
	data['smoking'],  # 1 for smoking, 0 for non-smoking
        data['cigarettes_per_day'],
        data['bpmeds'],
        data['prevalent_stroke'],
        data['prevalent_hyp'],
        data['diabetes'],
	data['cholesterol'],
        data['systolic_blood_pressure'],
        data['diastolic_blood_pressure'],
        data['bmi'],
        data['heart_rate'],
        data['glucose_level']
    ])  # Convert to DataFrame for consistent processing
    
    # Scale the input data
    input_data_scaled = scaler.transform(np.array(input_data_df).reshape(1, -1))
    
    # Make predictions for each model
    log_pred_proba = log_model.predict_proba(input_data_scaled)[:, 1]
    rf_pred_proba = rf_model.predict_proba(input_data_scaled)[:, 1]
    xgb_pred_proba = xgb_model.predict_proba(input_data_scaled)[:, 1]

    # Determine which model to use based on the highest accuracy
    best_proba = None
    best_class = None
    best_model_name = None

    # Compare the models' accuracies and select the best one
    models = {
        'Logistic Regression': (accuracy_log, log_pred_proba),
        'Random Forest': (accuracy_rf, rf_pred_proba),
        'XGBoost': (accuracy_xgb, xgb_pred_proba)
    }

    best_accuracy = 0
    for model_name, (accuracy, pred_proba) in models.items():
        if accuracy > best_accuracy:
            best_accuracy = accuracy
            best_model_name = model_name
            best_proba = pred_proba

    # Determine the class based on the best probability
    best_class = (best_proba >= 0.5).astype(int)[0]

    # Convert to percentage
    final_pred_proba_percentage = float(best_proba[0]) * 100

    # Return the result
    result = {
        'prediction': final_pred_proba_percentage,
        'class': int(best_class),
        'model_used': best_model_name
    }
    
    return jsonify(result)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))  # Default to 5000 if PORT is not set
    app.run(host="0.0.0.0", port=port,debug=True) 
