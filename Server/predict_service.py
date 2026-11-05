import sys
import json
import pickle
import pandas as pd
import os

# Path ke artefak model pkl
MODEL_PATH = os.path.join(os.path.dirname(__file__), '../Modelling/notebooks/artifacts/best_churn_pipeline.pkl')

try:
    with open(MODEL_PATH, 'rb') as f:
        model_pipeline = pickle.load(f)
except Exception as e:
    print(json.dumps({"error": f"Gagal memuat model: {str(e)}"}))
    sys.exit(1)

def predict():
    try:
        # Membaca data masukan dari argumen terminal (JSON string)
        input_raw = json.loads(sys.argv[1])
        df_input = pd.DataFrame([input_raw])
        
        # Prediksi menggunakan Pipeline
        pred_class = int(model_pipeline.predict(df_input)[0])
        pred_proba = float(model_pipeline.predict_proba(df_input)[:, 1][0])
        
        # Penentuan Kategori Risiko Bisnis
        if pred_proba > 0.7:
            risk_level = "HIGH RISK"
        elif pred_proba > 0.4:
            risk_level = "MEDIUM RISK"
        else:
            risk_level = "LOW RISK"

        result = {
            "is_churn": pred_class == 1,
            "churn_probability": round(pred_proba * 100, 2),
            "risk_level": risk_level
        }
        print(json.dumps(result))
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    predict()