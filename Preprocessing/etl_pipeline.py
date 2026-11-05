import os
import glob
import pandas as pd
import yfinance as yf
import kagglehub
from sqlalchemy import create_engine
from datetime import datetime
from elasticsearch import Elasticsearch, helpers

# ==========================================
# 1. SETUP KONEKSI DATABASE & ELASTICSEARCH
# ==========================================
DB_URL = "postgresql://admin:adminpassword@127.0.0.1:5434/fintech_dw"
engine = create_engine(DB_URL)

# Perbaikan 1: Kurangi timeout global & pastikan header kompatibilitas v8
es = Elasticsearch(
    ["http://localhost:9200"],
    headers={
        "Accept": "application/vnd.elasticsearch+json; compatible-with=8",
        "Content-Type": "application/vnd.elasticsearch+json; compatible-with=8"
    },
    request_timeout=60,
    max_retries=3,
    retry_on_timeout=True
)

def run_etl():
    print("🚀 Memulai proses ETL Pipeline & Elasticsearch Indexing...")

    # ==========================================
    # 2. EXTRACT DATA
    # ==========================================
    print("📥 Mengunduh dataset dari Kaggle via KaggleHub...")
    kaggle_path = kagglehub.dataset_download("saurabhbadole/bank-customer-churn-prediction-dataset")
    csv_files = glob.glob(os.path.join(kaggle_path, "*.csv"))
    if not csv_files:
        raise FileNotFoundError("File CSV dari Kaggle tidak ditemukan!")
    
    raw_df = pd.read_csv(csv_files[0])
    print(f"✅ Data Kaggle berhasil dimuat: {len(raw_df)} baris")

    print("📈 Mengambil data pasar keuangan real-time (USD/IDR via YFinance)...")
    ticker = yf.Ticker("IDR=X")
    market_data = ticker.history(period="1d")
    latest_rate = market_data['Close'].iloc[-1]
    today_date = datetime.now().strftime('%Y-%m-%d')
    print(f"✅ Data Real-time dimuat: USD/IDR = {latest_rate:.2f}")

    # ==========================================
    # 3. TRANSFORM DATA
    # ==========================================
    print("⚙️ Melakukan Transformasi Data & Feature Engineering...")
    raw_df.columns = [col.strip() for col in raw_df.columns]
    
    raw_df['Balance_Salary_Ratio'] = (raw_df['Balance'] / raw_df['EstimatedSalary']).round(4)
    raw_df['Ingestion_Date'] = today_date

    # --- Data Warehouse Star Schema (PostgreSQL) ---
    dim_customer = raw_df[['CustomerId', 'CreditScore', 'Geography', 'Gender', 'Age', 'EstimatedSalary']].drop_duplicates()
    dim_customer.columns = ['customer_id', 'credit_score', 'geography', 'gender', 'age', 'estimated_salary']

    dim_account = raw_df[['CustomerId', 'Tenure', 'NumOfProducts', 'HasCrCard', 'IsActiveMember']].copy()
    dim_account.columns = ['customer_id', 'tenure', 'num_of_products', 'has_cr_card', 'is_active_member']

    dim_market = pd.DataFrame([{
        'date': today_date,
        'usd_to_idr': round(latest_rate, 2),
        'interest_rate': 6.00
    }])

    fact_churn = raw_df[['CustomerId', 'Balance', 'Exited']].copy()
    fact_churn['date'] = today_date
    fact_churn.columns = ['customer_id', 'balance', 'exited', 'date']

    # ==========================================
    # 4. LOAD TO POSTGRESQL (Data Warehouse)
    # ==========================================
    print("💾 Memasukkan data ke Data Warehouse PostgreSQL...")
    dim_customer.to_sql('dim_customer', engine, if_exists='replace', index=False)
    dim_account.to_sql('dim_account', engine, if_exists='replace', index=False)
    dim_market.to_sql('dim_market_context', engine, if_exists='append', index=False)
    fact_churn.to_sql('fact_customer_churn', engine, if_exists='replace', index=False)
    print("✅ Postgres DW terisi!")

    # ==========================================
    # 5. LOAD TO ELASTICSEARCH (Untuk Dashboard Kibana)
    # ==========================================
    print("🔍 Mengindeks data ke Elasticsearch (Index: 'bank_customers')...")
    
    records = raw_df.to_dict(orient='records')
    
    def doc_generator(docs):
        for doc in docs:
            yield {
                "_index": "bank_customers",
                "_source": doc
            }

    # Perbaikan Utama:
    # 1. Ubah chunk_size ke 100 agar beban memori Elasticsearch di Docker ringan.
    # 2. Tambahkan request_timeout=60 langsung di helpers.bulk.
    # 3. Gunakan stats_only=True untuk memproses stream secara stabil.
    success_count, _ = helpers.bulk(
        es, 
        doc_generator(records), 
        chunk_size=100,
        request_timeout=60,
        stats_only=True
    )
    print(f"✅ Elasticsearch Indexing selesai! Berhasil mengindeks {success_count} dokumen.")
    print("🎉 Pipeline Tahap 1 Sukses! PostgreSQL & Elasticsearch siap digunakan.")

if __name__ == "__main__":
    run_etl()