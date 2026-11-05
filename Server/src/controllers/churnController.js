const { execFile } = require('child_process');
const path = require('path');
const db = require('../config/db');

// 1. Get Summary Stats dari PostgreSQL Data Warehouse
exports.getChurnStats = async (req, res) => {
    try {
        const query = `
            SELECT 
                COUNT(*)::text AS total_customers,
                SUM(CASE WHEN exited = 1 THEN 1 ELSE 0 END)::text AS total_churned,
                ROUND(
                    ((SUM(CASE WHEN exited = 1 THEN 1 ELSE 0 END)::decimal / NULLIF(COUNT(*), 0)) * 100)::numeric, 
                    1
                )::text AS churn_rate,
                ROUND(
                    AVG(balance)::numeric, 
                    2
                )::text AS avg_balance
            FROM fact_customer_churn;
        `;
        const result = await db.query(query);
        const stats = result.rows[0] || {};

        // Konversi eksplisit ke Number sebelum di-serialize ke JSON
        res.status(200).json({
            success: true,
            data: {
                totalCustomers: Number(stats.total_customers) || 0,
                totalChurned: Number(stats.total_churned) || 0,
                churnRate: Number(stats.churn_rate) || 0.0,
                avgBalance: Number(stats.avg_balance) || 0.0
            }
        });
    } catch (error) {
        console.error("Database Error:", error.message);
        res.status(500).json({ success: false, message: error.message });
    }
};

// 2. Predict Customer Churn
exports.predictCustomerChurn = async (req, res) => {
    const customerData = req.body;
    const scriptPath = path.join(__dirname, '../../predict_service.py');

    execFile('python', [scriptPath, JSON.stringify(customerData)], (error, stdout, stderr) => {
        if (error) {
            return res.status(500).json({ success: false, message: "Gagal eksekusi ML Service", error: stderr });
        }
        try {
            const result = JSON.parse(stdout);
            if (result.error) {
                return res.status(400).json({ success: false, message: result.error });
            }
            res.status(200).json({ success: true, data: result });
        } catch (e) {
            res.status(500).json({ success: false, message: "Response dari Python ML invalid" });
        }
    });
};