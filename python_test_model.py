import joblib
import numpy as np

# Load the models
log_model = joblib.load('logistic_regression_model.pkl')
rf_model = joblib.load('random_forest_model.pkl')
xgb_model = joblib.load('xgboost_model.pkl')
scaler = joblib.load('scaler.pkl')

# Example input data (ensure this matches your model's expected input shape)
input_data = np.array([[1, 41, 0, 0, 0, 0, 0, 0, 195, 139, 88, 26.88, 85, 65]])

# Scale the input data
input_data_scaled = scaler.transform(input_data)

# Make predictions
log_proba = log_model.predict_proba(input_data_scaled)[0][1] * 100  # Probability for class 1
rf_proba = rf_model.predict_proba(input_data_scaled)[0][1] * 100
xgb_proba = xgb_model.predict_proba(input_data_scaled)[0][1] * 100

print(f"Logistic Regression Probability: {log_proba:.2f}%")
print(f"Random Forest Probability: {rf_proba:.2f}%")
print(f"XGBoost Probability: {xgb_proba:.2f}%")
