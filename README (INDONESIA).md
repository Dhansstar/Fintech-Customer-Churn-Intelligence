# 🏦 Enterprise Bank Customer Churn Analytics & Live Inference Engine

Solusi analitik terintegrasi secara *End-to-End* berbasis Machine Learning untuk mendeteksi risiko *Customer Churn* (kepindahan nasabah) di industri perbankan retail. 

Aplikasi ini mengintegrasikan **Machine Learning Pipeline (Scikit-Learn Decision Tree)** yang dilatih pada Jupyter Notebook dengan **Backend API Gateway (Node.js/Express.js)**, **PostgreSQL Data Warehouse**, **Elasticsearch**, dan antarmuka **Aplikasi Flutter Cross-Platform (Android & Web)** dengan arsitektur bersih (*Clean Architecture*) serta GetX State Management.

---

## 📑 Daftar Isi
1. [Arsitektur System (End-to-End Flow)](#-arsitektur-system-end-to-end-flow)
2. [Struktur Folder & Repositori](#-struktur-folder--repositori)
3. [Detail Modelling Machine Learning](#-detail-modelling-machine-learning)
4. [Skema Database & Search Engine](#-skema-database--search-engine)
5. [Panduan Instalasi & Cara Menjalankan](#-panduan-instalasi--cara-menjalankan)
   - [1. Prasyarat Sistem](#1-prasyarat-sistem)
   - [2. Preprocessing & Infrastructure (Docker)](#2-preprocessing--infrastructure-docker)
   - [3. Eksperimen Machine Learning (Notebook)](#3-eksperimen-machine-learning-notebook)
   - [4. Backend Server (Express.js Gateway)](#4-backend-server-expressjs-gateway)
   - [5. Frontend Client (Aplikasi Flutter)](#5-frontend-client-aplikasi-flutter)
6. [API Endpoints Documentation](#-api-endpoints-documentation)
7. [Penjelasan Fitur Aplikasi Flutter](#-penjelasan-fitur-aplikasi-flutter)

---

## 📐 Arsitektur System (End-to-End Flow)

```text
[ Kaggle Churn Data ] ──> [ Python ETL Pipeline ] ──┬──> [ PostgreSQL DW (Port 5434) ] ──> [ Express.js API Gateway ] ──> [ Flutter Client App ]
[ YFinance USD/IDR  ]                              └──> [ Elasticsearch (Port 9200) ]            │ (Port 5000)                   │
                                                                                                 │                               │
                                    [ Jupyter Notebook ML ] ──> [ best_churn_pipeline.pkl ] ─────┘ (Python Bridge Execution) ────┘
```

---

## 🗂️ Struktur Folder & Repositori

```text
├── Modelling/
│   ├── notebooks/
│   │   ├── artifacts/
│   │   │   └── best_churn_pipeline.pkl    # Artefak Model Pipeline Scikit-Learn Terbaik
│   │   ├── churn_analysis.ipynb          # Notebook Eksperimen Modeling 1, 2, 3 & Evaluasi ROC-AUC
│   │   ├── dataset_1.csv                 # Dataset Baseline Kaggle
│   │   ├── dataset_2.csv                 # Dataset Enhanced (Feature Engineering)
│   │   └── model_inference.ipynb         # Notebook Khusus Model Inference Data Baru
│   ├── saved_models/                     # Legacy XGBoost Models
│   └── train_xgboost.py                  # Script Python Training XGBoost
│
├── Preprocessing/
│   ├── docker-compose.yml                # Konfigurasi Container PostgreSQL DW & Elasticsearch
│   └── etl_pipeline.py                   # Script ETL Otomatisasi Extrak, Transformasi & Loading Data
│
├── Server/
│   ├── src/
│   │   ├── config/                       # Koneksi Database PostgreSQL & Elasticsearch
│   │   ├── controllers/                  # Controller Handling Stats & Prediction
│   │   ├── models/                       # Model Query Data
│   │   └── routes/                       # Express Router API Routes
│   ├── predict_service.py                # Bridge Python Service untuk Memuat .pkl Model
│   ├── index.js                          # Point Masuk Server Node.js Express
│   └── package.json
│
└── App/                                  # Flutter App Client Layer
    └── lib/
        ├── controllers/                  # Controller GetX (dashboard_controller.dart)
        ├── core/
        │   ├── theme/                    # Theme & Styling Aplikasi
        │   └── widgets/                  # Widget Reusable (StatCard, CustomButton)
        ├── models/                       # Type-Safe Models (PredictionResultModel, ChurnStatsModel)
        ├── services/                     # Service HTTP API Callers (api_service.dart)
        ├── views/                        # Tampilan UI (DashboardView, PredictFormView, MainNavigationView)
        └── main.dart                     # App Entry Point (GetMaterialApp)
```

---

## 📊 Detail Modelling Machine Learning

* **Target Variable:** `Exited` / Churn Status (`1` = Churn/Keluar, `0` = Retained/Bertahan)
* **Algoritma yang Diuji:** Logistic Regression & Decision Tree Classifier
* **Model Terbaik:** Decision Tree Classifier yang di-tuning menggunakan `GridSearchCV` (`max_depth=5`, `min_samples_split=5`).
* **Feature Engineering (`dataset_2.csv`):**
  * `Balance_Salary_Ratio`: Rasio saldo terhadap estimasi gaji ($\text{Balance} / \text{EstimatedSalary}$).
  * `USD_TO_IDR`: Kurs makro finansial real-time yang diambil via API YFinance.
* **Feature Selection & Hygiene:** Menggunakan `SelectKBest` ($k=8$) di dalam objek Scikit-Learn `Pipeline` terisolasi untuk mencegah *Data Leakage*.
* **Evaluasi Performa Model:** ROC-AUC Score **> 0.91** (Kategori Evaluasi **Good**).

---

## 🗄️ Skema Database & Search Engine

### 1. PostgreSQL Data Warehouse (Star Schema)
* **Port Host:** `5434` (Database: `fintech_dw`)
* **Tabel Utama:** `fact_customer_churn`
* **Metrik Utama yang Diagregasi:** Total Customers ($10,000$), Overall Churn Rate ($20.4\%$), dan Average Account Balance ($\$76,485.89$).

### 2. Elasticsearch Search Engine
* **Port Host:** `9200`
* **Indeks:** `bank_churn_index` (Mengindeks data 10.000 dokumen nasabah menggunakan alokasi `chunk_size=100` untuk mendukung pencarian cepat dan analitik *real-time*).

---

## 🛠️ Panduan Instalasi & Cara Menjalankan

### 1. Prasyarat Sistem
Pastikan perangkat kamu telah terinstal program berikut:
* **Docker Desktop** (dengan fitur Docker Compose aktif)
* **Node.js** (v16.x atau v18.x)
* **Python** (v3.9+ dengan package `pandas`, `scikit-learn`, `yfinance`, `kagglehub`)
* **Flutter SDK** (v3.0+)

---

### 2. Preprocessing & Infrastructure (Docker)

1. Buka terminal dan masuk ke folder `Preprocessing/`:
   ```bash
   cd Preprocessing
   ```
2. Jalankan container PostgreSQL dan Elasticsearch:
   ```bash
   docker-compose up -d
   ```
3. Eksekusi script ETL untuk mengunduh dataset Kaggle & YFinance, mentransformasi data, dan memasukkannya ke database:
   ```bash
   python etl_pipeline.py
   ```

---

### 3. Eksperimen Machine Learning (Notebook)

1. Masuk ke folder `Modelling/notebooks/`.
2. Buka dan jalankan seluruh cell pada file `churn_analysis.ipynb`.
3. Script akan secara otomatis melakukan training, evaluasi ROC-AUC, hyperparameter tuning, dan mengekspor model pipeline terbaik ke path:
   ```text
   Modelling/notebooks/artifacts/best_churn_pipeline.pkl
   ```

---

### 4. Backend Server (Express.js Gateway)

1. Buka terminal baru dan masuk ke folder `Server/`:
   ```bash
   cd Server
   ```
2. Instal dependensi Node.js:
   ```bash
   npm install
   ```
3. Jalankan server pengembangan Backend:
   ```bash
   npm run dev
   ```
   * *Server API Gateway akan aktif pada:* `http://localhost:5000`

---

### 5. Frontend Client (Aplikasi Flutter)

1. Buka terminal baru dan masuk ke folder `App/`:
   ```bash
   cd App
   ```
2. Ambil seluruh package Flutter:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi Flutter:
   * **Untuk Pengujian di Chrome Browser:**
     ```bash
     flutter run -d chrome
     ```
   * **Untuk Pengujian di Android Emulator (Pixel 7):**
     ```bash
     flutter run
     ```
     *(Catatan: Android Emulator terhubung secara otomatis ke host via IP `http://10.0.2.2:5000`)*

---

## 🌐 API Endpoints Documentation

| HTTP Method | Endpoint Path | Deskripsi | Respons Data |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/churn/stats` | Mengambil data agregat makro dari PostgreSQL DW | Total Customers, Total Churned, Churn Rate %, Avg Balance |
| **POST** | `/api/v1/churn/predict` | Memicu prediksi ML live via `predict_service.py` (`.pkl`) | `is_churn` (boolean), `churn_probability` (%), `risk_level` |

#### Contoh Payload `POST /api/v1/churn/predict`:
```json
{
  "CreditScore": 650,
  "Geography": "France",
  "Gender": "Female",
  "Age": 42,
  "Tenure": 5,
  "Balance": 75000.0,
  "NumOfProducts": 1,
  "HasCrCard": 1,
  "IsActiveMember": 0,
  "EstimatedSalary": 50000.0,
  "Balance_Salary_Ratio": 1.5,
  "USD_TO_IDR": 15800.0
}
```

---

## 📱 Penjelasan Fitur Aplikasi Flutter

1. **Tab Dashboard (Data Warehouse Metrics):**
   * Menyajikan *real-time metrics* dari PostgreSQL Data Warehouse (Total Customers, Churn Rate, dan Average Balance).
2. **Tab Inference ML (Simulasi Prediksi Churn Live):**
   * Memungkinkan pengguna (seperti *Relationship Manager* atau *Customer Service* bank) menginput karakteristik nasabah baru secara bebas.
   * Menampilkan hasil analisa model `.pkl` secara *live* berupa kategori risiko (**HIGH RISK**, **MEDIUM RISK**, **LOW RISK**), persentase probabilitas churn, dan rekomendasi langkah retensi bisnis.

---

## ✒️ Identitas & Lisensi

* **Pengembang:** Risyadhana
* **Spesialisasi:** Data Analytics & Machine Learning / Fullstack Integration