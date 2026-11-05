# 🏦 Enterprise Bank Customer Churn Analytics & Live Inference Engine

An end-to-end Machine Learning & Financial Analytics System designed to predict retail bank customer churn risk and display enterprise-level Data Warehouse metrics.

This project integrates a **Machine Learning Pipeline (Scikit-Learn Decision Tree)** trained in Python/Jupyter Notebooks with a **Node.js/Express.js Backend API Gateway**, **PostgreSQL Data Warehouse**, **Elasticsearch**, and a **Flutter Mobile/Web Application** built using Clean Architecture and GetX State Management.

## 📑 Table of Contents

1. [System Architecture (End-to-End Flow)](#-system-architecture-end-to-end-flow)
2. [Project Directory Structure](#-project-directory-structure)
3. [Machine Learning Details](#-machine-learning-details)
4. [Database & Search Engine Schema](#-database--search-engine-schema)
5. [Installation & Setup Guide](#-installation--setup-guide)
   * [1. Prerequisites](#1-prerequisites)
   * [2. Preprocessing & Infrastructure Setup](#2-preprocessing--infrastructure-setup)
   * [3. Machine Learning Notebook Execution](#3-machine-learning-notebook-execution)
   * [4. Backend Server Setup](#4-backend-server-setup)
   * [5. Frontend Client Setup](#5-frontend-client-setup)
6. [API Endpoints Documentation](#-api-endpoints-documentation)
7. [Flutter Application Features](#-flutter-application-features)
8. [Author & License](#-author--license)

---

## 📐 System Architecture (End-to-End Flow)

```
[ Kaggle Churn Data ] ──> [ Python ETL Pipeline ] ──┬──> [ PostgreSQL DW (Port 5434) ] ──> [ Express.js API Gateway ] ──> [ Flutter Client App ]
[ YFinance USD/IDR  ]                              └──> [ Elasticsearch (Port 9200) ]            │ (Port 5000)                   │
                                                                                                 │                               │
                                    [ Jupyter Notebook ML ] ──> [ best_churn_pipeline.pkl ] ─────┘ (Python Bridge Execution) ────┘
```

---

## 🗂️ Project Directory Structure

```text
├── Modelling/
│   ├── notebooks/
│   │   ├── artifacts/
│   │   │   └── best_churn_pipeline.pkl    # Trained Scikit-Learn Model Pipeline
│   │   ├── churn_analysis.ipynb          # Model Training & ROC-AUC Notebook
│   │   ├── dataset_1.csv                 # Baseline Kaggle Dataset
│   │   ├── dataset_2.csv                 # Enhanced Dataset with Feature Engineering
│   │   └── model_inference.ipynb         # Standalone Model Inference Notebook
│   ├── saved_models/                     # Legacy XGBoost Models
│   └── train_xgboost.py                  # XGBoost Training Script
│
├── Preprocessing/
│   ├── docker-compose.yml                # Docker Infrastructure (PostgreSQL DW & Elasticsearch)
│   └── etl_pipeline.py                   # Automated Data Pipeline & Ingestion Script
│
├── Server/
│   ├── src/
│   │   ├── config/                       # PostgreSQL & Elasticsearch Connection Configs
│   │   ├── controllers/                  # Churn Stats & Prediction Controllers
│   │   ├── models/                       # Database Models
│   │   └── routes/                       # Express Router API Endpoints
│   ├── predict_service.py                # Python Bridge Script for ML Inference
│   ├── index.js                          # Node.js Express Gateway Entry Point
│   └── package.json
│
└── App/                                  # Flutter Mobile / Web Client Application
    └── lib/
        ├── controllers/                  # GetX Controllers (dashboard_controller.dart)
        ├── core/
        │   ├── theme/                    # App Styling & Colors
        │   └── widgets/                  # Reusable UI Widgets (stat_card.dart)
        ├── models/                       # Strongly-Typed Dart Models (PredictionResultModel)
        ├── services/                     # HTTP API Service (api_service.dart)
        ├── views/                        # UI Views (DashboardView, PredictFormView, MainNavigationView)
        └── main.dart                     # App Entry Point (GetMaterialApp)
```

---

## 📊 Machine Learning Details

* **Target Variable:** `Exited` / Churn Status (`1` = Churned, `0` = Retained)
* **Algorithms Tested:** Logistic Regression & Decision Tree Classifier
* **Best Model:** Decision Tree Classifier hyperparameter tuned using `GridSearchCV` (`max_depth=5`, `min_samples_split=5`).
* **Feature Engineering (`dataset_2.csv`):**
  * `Balance_Salary_Ratio`: Ratio of account balance to estimated salary ($\text{Balance} / \text{EstimatedSalary}$).
  * `USD_TO_IDR`: Live FX macro rate fetched via YFinance API.
* **Feature Selection & Data Hygiene:** `SelectKBest` ($k=8$) encapsulated inside a Scikit-Learn `Pipeline` to prevent Data Leakage.
* **Model Performance:** ROC-AUC Score **> 0.91** (Rated as **Good**).

---

## 🗄️ Database & Search Engine Schema

### 1. PostgreSQL Data Warehouse (Star Schema)
* **Host Port:** `5434` (Database: `fintech_dw`)
* **Primary Fact Table:** `fact_customer_churn`
* **Aggregated Macro Metrics:** Total Customers ($10,000$), Overall Churn Rate ($20.4\%$), and Average Account Balance ($\$76,485.89$).

### 2. Elasticsearch Search Engine
* **Host Port:** `9200`
* **Index:** `bank_churn_index` (Indexes 10,000 customer records with a batch `chunk_size=100` allocation for rapid search and real-time analytics).

---

## 🛠️ Installation & Setup Guide

### 1. Prerequisites
Ensure you have the following installed on your local development machine:
* **Docker Desktop** (with Docker Compose enabled)
* **Node.js** (v16.x or v18.x)
* **Python** (v3.9+ with `pandas`, `scikit-learn`, `yfinance`, and `kagglehub` installed)
* **Flutter SDK** (v3.0+)

### 2. Preprocessing & Infrastructure Setup

1. Open your terminal and navigate to the `Preprocessing/` directory:
   ```bash
   cd Preprocessing
   ```

2. Start the PostgreSQL Data Warehouse and Elasticsearch services via Docker:
   ```bash
   docker-compose up -d
   ```

3. Execute the ETL script to download the Kaggle dataset, fetch YFinance market rates, transform the data, and load it into PostgreSQL & Elasticsearch:
   ```bash
   python etl_pipeline.py
   ```

### 3. Machine Learning Notebook Execution

1. Navigate to `Modelling/notebooks/`.
2. Open and run all cells in `churn_analysis.ipynb`.
3. The script will train the models, perform cross-validation, tune hyperparameters, and export the best pipeline artifact to:
   ```text
   Modelling/notebooks/artifacts/best_churn_pipeline.pkl
   ```

### 4. Backend Server Setup

1. Open a new terminal window and navigate to the `Server/` directory:
   ```bash
   cd Server
   ```

2. Install the required Node.js dependencies:
   ```bash
   npm install
   ```

3. Launch the development backend server:
   ```bash
   npm run dev
   ```
   * *API Gateway Server running on:* `http://localhost:5000`

### 5. Frontend Client Setup

1. Open a new terminal window and navigate to the `App/` directory:
   ```bash
   cd App
   ```

2. Get all Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   * **For Web Browser:**
     ```bash
     flutter run -d chrome
     ```
   * **For Android Emulator (e.g., Pixel 7):**
     ```bash
     flutter run
     ```
     *(Note: Android Emulator automatically connects to localhost via `http://10.0.2.2:5000`)*

---

## 🌐 API Endpoints Documentation

| HTTP Method | Endpoint Path | Description | Response Data |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/churn/stats` | Fetches aggregated Data Warehouse statistics | Total Customers, Total Churned, Churn Rate %, Avg Balance |
| **POST** | `/api/v1/churn/predict` | Executes live inference via `predict_service.py` (`.pkl`) | `is_churn` (boolean), `churn_probability` (%), `risk_level` |

#### Sample Payload for `POST /api/v1/churn/predict`:
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

## 📱 Flutter Application Features

1. **Dashboard Tab (Data Warehouse Metrics):**
   * Displays real-time macro statistics loaded directly from the PostgreSQL Data Warehouse (Total Customers, Churn Rate, Average Balance).
2. **Inference ML Tab (Live Risk Predictor):**
   * Allows banking relationship managers or customer service personnel to input individual customer attributes.
   * Renders instant predictions from the `.pkl` pipeline model, showing Risk Level categorization (**HIGH RISK**, **MEDIUM RISK**, **LOW RISK**), exact Churn Probability %, and automated retention advice.

---

## ✒️ Author & License

* **Developer:** Risyadhana
* **Specialization:** Data Analytics & Machine Learning / Fullstack Mobile & Web Engineering
