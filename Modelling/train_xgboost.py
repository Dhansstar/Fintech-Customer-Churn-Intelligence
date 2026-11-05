import os
import joblib
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, roc_auc_score
import xgboost as xgb
import shap

# 1. KONEKSI KE POSTGRESQL DATA WAREHOUSE
DB_URL = "postgresql://admin:adminpassword@127.0.0.1:5434/fintech_dw"
engine = create_engine(DB_URL)

def run_model_training():
    print("🚀 Memuat data dari Data Warehouse PostgreSQL...")
    
    # Query SQL Join Antara Fact dan Dimension Tables
    query = """
    SELECT 
        c.credit_score,
        c.geography,
        c.gender,
        c.age,
        c.estimated_salary,
        a.tenure,
        a.num_of_products,
        a.has_cr_card,
        a.is_active_member,
        f.balance,
        f.exited
    FROM fact_customer_churn f
    JOIN dim_customer c ON f.customer_id = c.customer_id
    JOIN dim_account a ON f.customer_id = a.customer_id;
    """
    
    df = pd.read_sql(query, engine)
    print(f"✅ Data dimuat: {len(df)} baris")

    # 2. FEATURE ENGINEERING & PREPROCESSING
    print("⚙️ Melakukan Feature Engineering...")
    # Feature Ratio
    df['balance_salary_ratio'] = (df['balance'] / df['estimated_salary']).replace([np.inf, -np.inf], 0).fillna(0)
    df['product_engagement'] = df['num_of_products'] * df['is_active_member']
    
    # One-Hot Encoding untuk Variabel Kategori (Geography & Gender)
    df_encoded = pd.get_dummies(df, columns=['geography', 'gender'], drop_first=True)

    X = df_encoded.drop(columns=['exited'])
    y = df_encoded['exited']

    # Split Data (80% Train, 20% Test)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    # 3. TRAINING MODEL XGBOOST
    print("🤖 Melatih Model XGBoost Classifier...")
    model = xgb.XGBClassifier(
        n_estimators=100,
        max_depth=5,
        learning_rate=0.08,
        random_state=42,
        eval_metric='logloss'
    )
    model.fit(X_train, y_train)

    # Evaluasi Model
    y_pred = model.predict(X_test)
    y_proba = model.predict_proba(X_test)[:, 1]
    
    print("\n📊 --- PERFORMA MODEL CHURN ---")
    print(f"ROC-AUC Score: {roc_auc_score(y_test, y_proba):.4f}")
    print(classification_report(y_test, y_pred))

    # 4. SHAP EXPLAINER (INTERPRETABILITAS METRIK BANK)
    print("💡 Mengalkulasi SHAP Explainer untuk Fitur Penting...")
    explainer = shap.TreeExplainer(model)
    shap_values = explainer(X_test)

    # 5. SIMPAN MODEL & ARTEFAK
    output_dir = os.path.join(os.path.dirname(__file__), "saved_models")
    os.makedirs(output_dir, exist_ok=True)

    model_path = os.path.join(output_dir, "xgboost_churn_model.pkl")
    explainer_path = os.path.join(output_dir, "shap_explainer.pkl")
    columns_path = os.path.join(output_dir, "model_columns.pkl")

    joblib.dump(model, model_path)
    joblib.dump(explainer, explainer_path)
    joblib.dump(X.columns.tolist(), columns_path)

    print(f"🎉 Model & SHAP Explainer berhasil disimpan di folder: {output_dir}")

if __name__ == "__main__":
    run_model_training()